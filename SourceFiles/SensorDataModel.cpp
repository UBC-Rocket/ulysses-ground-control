#include "SensorDataModel.h"
#include "SerialBridge.h"
#include "rp/codec.h"
#include "downlink.pb.h"
#include <QDebug>
#include <QtMath>
#include <cmath>

static constexpr bool kSerialDebug = false;

namespace {
// Quaternion (w,x,y,z) to Euler angles (roll, pitch, yaw) in radians.
void quatToEulerRad(float w, float x, float y, float z,
                    float* roll_rad, float* pitch_rad, float* yaw_rad) {
    double sinp = 2.0 * (w * y - z * x);
    if (std::abs(sinp) >= 1) {
        *pitch_rad = static_cast<float>(std::copysign(M_PI / 2, sinp));
    } else {
        *pitch_rad = static_cast<float>(std::asin(sinp));
    }
    double siny_cosp = 2.0 * (w * z + x * y);
    double cosy_cosp = 1.0 - 2.0 * (y * y + z * z);
    *yaw_rad = static_cast<float>(std::atan2(siny_cosp, cosy_cosp));
    double sinr_cosp = 2.0 * (w * x + y * z);
    double cosr_cosp = 1.0 - 2.0 * (x * x + y * y);
    *roll_rad = static_cast<float>(std::atan2(sinr_cosp, cosr_cosp));
}

float radToDeg(float rad) {
    return static_cast<float>(rad * 180.0 / M_PI);
}
} // namespace

SensorDataModel::SensorDataModel(SerialBridge* bridge, QObject* parent)
    : m_bridge(bridge), QObject(parent)
{
    if (!m_bridge)
        return; // No source of lines if bridge is null.

    // Subscribe to binary COBS packets (primary: rocket sends COBS+protobuf Downlink).
    QObject::connect(
        m_bridge,
        &SerialBridge::binaryPacketReceived,
        this,
        [this](int which, const QByteArray &packet) {
            if (!m_bridge) return;
            const bool p1 = m_bridge->isConnected(1);
            const bool p2 = m_bridge->isConnected(2);
            bool listen = (p1 && p2) ? (which == 1) : m_bridge->isConnected(which);
            if (listen)
                onBinaryPacketReceived(which, packet);
        });

    // Also subscribe to text lines (e.g. legacy CSV or debug output).
    QObject::connect(
        m_bridge,
        &SerialBridge::textReceivedFrom,
        this,
        [this](int which, const QString &line) {
            if (!m_bridge) return;
            const bool p1 = m_bridge->isConnected(1);
            const bool p2 = m_bridge->isConnected(2);
            bool listen = (p1 && p2) ? (which == 1) : m_bridge->isConnected(which);
            if (listen)
                onLineReceived(line);
        });
}

void SensorDataModel::onLineReceived(const QString& line)
{
    parseIncomingData(line);
}

void SensorDataModel::onBinaryPacketReceived(int which, const QByteArray& packet)
{
    if (packet.isEmpty())
        return;

    tvr_Downlink downlink = tvr_Downlink_init_default;
    const uint8_t* data = reinterpret_cast<const uint8_t*>(packet.constData());
    size_t size = static_cast<size_t>(packet.size());

    rp_packet_decode_result_t result =
        rp_packet_decode(data, size, &tvr_Downlink_msg, &downlink);

    if (result.status != RP_CODEC_OK)
        return; // Bad checksum or malformed packet; skip silently or log occasionally.

    applyDownlink(which, &downlink);
}

void SensorDataModel::parseIncomingData(const QString& line)
{
    // Ignore completely empty / whitespace-only lines.
    if (line.trimmed().isEmpty())
        return;

    // Incoming CSV, comma-separated values.
    QStringList parts = line.split(',', Qt::SkipEmptyParts);

    // Expected format (12 fields):
    // pressure,altitude,raw_angle_x,filtered_angle_x,raw_angle_y,filtered_angle_y,raw_angle_z,filtered_angle_z,velocity,temperature,signal,battery
    if (parts.size() != 12) {
        // Throttle warnings so high-rate streams don’t flood the log.
        static int errorCount = 0;
        if (++errorCount % 50 == 0) {
            qWarning() << "Expected 12 CSV fields, got"
                       << parts.size() << "in line:" << line;
        }
        return;
    }

    double pressure        = parts[0].toDouble();
    double altitude        = parts[1].toDouble();
    double rawAngleX       = parts[2].toDouble();
    double filteredAngleX  = parts[3].toDouble();
    double rawAngleY       = parts[4].toDouble();
    double filteredAngleY  = parts[5].toDouble();
    double rawAngleZ       = parts[6].toDouble();
    double filteredAngleZ  = parts[7].toDouble();
    double velocity        = parts[8].toDouble();
    double temperature     = parts[9].toDouble();
    double signal          = parts[10].toDouble();
    double battery         = parts[11].toDouble();

    if (kSerialDebug) {
        qDebug() << "| Baro:" << pressure << altitude
                 << "| Kalman:" << rawAngleX << filteredAngleX << rawAngleY << filteredAngleY << rawAngleZ << filteredAngleZ
                 << "| Telemetry:" << velocity << temperature << signal << battery;
    }

    // Update grouped values and notify QML bindings.
    updateKalman(rawAngleX, filteredAngleX, rawAngleY, filteredAngleY, rawAngleZ, filteredAngleZ);
    updateBaro(pressure, altitude);
    updateTelemetry(velocity, temperature, signal, battery);
}

void SensorDataModel::updateKalman(double rawAngleX, double filteredAngleX,
                                   double rawAngleY, double filteredAngleY,
                                   double rawAngleZ, double filteredAngleZ)
{
    // Cache latest angles and notify QML bindings.
    m_rawAngleX = rawAngleX;
    m_filteredAngleX = filteredAngleX;
    m_rawAngleY = rawAngleY;
    m_filteredAngleY = filteredAngleY;
    m_rawAngleZ = rawAngleZ;
    m_filteredAngleZ = filteredAngleZ;

    emit kalmanDataChanged();
}

void SensorDataModel::updateBaro(double pressure, double altitude)
{
    // Cache latest barometric readings and notify QML bindings.
    m_pressure = pressure;
    m_altitude = altitude;

    emit baroDataChanged();
}

void SensorDataModel::updateTelemetry(double velocity, double temperature,
                                      double signal, double battery)
{
    // Cache latest telemetry and notify QML bindings.
    m_velocity = velocity;
    m_temperature = temperature;
    m_signal = signal;
    m_battery = battery;

    emit telemetryDataChanged();
}

void SensorDataModel::applyDownlink(int which, const void* downlinkStruct)
{
    const tvr_Downlink* d = static_cast<const tvr_Downlink*>(downlinkStruct);

    if (d->which_payload == tvr_Downlink_telemetry_tag) {
        const tvr_TelemetryState* t = &d->payload.telemetry;

        // Velocity magnitude (m/s)
        double vel = 0.0;
        if (t->has_velocity) {
            const tvr_Vec3* v = &t->velocity;
            double vx = static_cast<double>(v->x), vy = static_cast<double>(v->y), vz = static_cast<double>(v->z);
            vel = std::sqrt(vx * vx + vy * vy + vz * vz);
        }

        // Euler angles (deg) from quaternion; use for both raw and filtered.
        double ax = 0.0, ay = 0.0, az = 0.0;
        if (t->has_attitude) {
            float roll, pitch, yaw;
            quatToEulerRad(t->attitude.w, t->attitude.x, t->attitude.y, t->attitude.z,
                           &roll, &pitch, &yaw);
            ax = radToDeg(roll);
            ay = radToDeg(pitch);
            az = radToDeg(yaw);
        }

        // Altitude from position.z (m); pressure not in proto, leave 0.
        double alt = 0.0;
        if (t->has_position)
            alt = static_cast<double>(t->position.z);

        updateKalman(ax, ax, ay, ay, az, az);
        updateBaro(0.0, alt);
        updateTelemetry(vel, 0.0, m_signal, m_battery); // keep last signal/battery
    } else if (d->which_payload == tvr_Downlink_status_tag) {
        const tvr_SystemStatus* s = &d->payload.status;
        // Expose radio RX count as "signal" for link health; leave others unchanged.
        updateTelemetry(m_velocity, m_temperature, static_cast<double>(s->radio_rx_count), m_battery);
    }
}
