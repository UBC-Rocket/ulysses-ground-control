#include "SensorDataModel.h"
#include "SerialBridge.h"
#include <QDebug>

static constexpr bool kSerialDebug = false;

SensorDataModel::SensorDataModel(SerialBridge* bridge, QObject* parent)
    : m_bridge(bridge), QObject(parent)
{
    if (!m_bridge)
        return; // No source of lines if bridge is null.

    // Subscribe once to SerialBridge lines and decide here whether to use each one.
    QObject::connect(
        m_bridge,
        &SerialBridge::textReceivedFrom,
        this,
        [this](int which, const QString &line) {
            if (!m_bridge)
                return; // Bridge pointer was cleared; ignore.

            const bool p1 = m_bridge->isConnected(1);
            const bool p2 = m_bridge->isConnected(2);

            bool listen = false;

            if (p1 && p2) {
                // Both ports up: treat port 1 as the primary sensor source.
                listen = (which == 1);
            } else if (p1 || p2) {
                // Only one port connected: accept data only from that port.
                listen = m_bridge->isConnected(which);
            } else {
                // No ports connected: drop everything.
                listen = false;
            }

            if (listen) {
                onLineReceived(line); // Forward accepted lines into the parser.
            }
        }
        );

    // Route parsed “sample” signals into state-updating slots so QML properties stay in sync.
    connect(this, &SensorDataModel::imuDataReceived,
            this, &SensorDataModel::updateIMU);
    connect(this, &SensorDataModel::kalmanDataReceived,
            this, &SensorDataModel::updateKalman);
    connect(this, &SensorDataModel::baroDataReceived,
            this, &SensorDataModel::updateBaro);
    connect(this, &SensorDataModel::telemetryDataReceived,
            this, &SensorDataModel::updateTelemetry);
}

void SensorDataModel::onLineReceived(const QString& line)
{
    parseIncomingData(line);
}

void SensorDataModel::parseIncomingData(const QString& line)
{
    // Ignore completely empty / whitespace-only lines.
    if (line.trimmed().isEmpty())
        return;

    // Incoming CSV, comma-separated values.
    QStringList parts = line.split(',', Qt::SkipEmptyParts);

    // Expected format (14 fields):
    // x,y,z,roll,pitch,yaw,pressure,altitude,
    // raw_angle,filtered_angle,velocity,temperature,signal,battery
    if (parts.size() != 14) {
        // Throttle warnings so high-rate streams don’t flood the log.
        static int errorCount = 0;
        if (++errorCount % 50 == 0) {
            qWarning() << "Expected 14 CSV fields, got"
                       << parts.size() << "in line:" << line;
        }
        return;
    }

    // IMU linear acceleration
    double x     = parts[0].toDouble();
    double y     = parts[1].toDouble();
    double z     = parts[2].toDouble();

    // IMU rotational rates
    double roll  = parts[3].toDouble();
    double pitch = parts[4].toDouble();
    double yaw   = parts[5].toDouble();

    // Barometric values
    double pressure = parts[6].toDouble();
    double altitude = parts[7].toDouble();

    // Kalman filter angles
    double rawAngle      = parts[8].toDouble();
    double filteredAngle = parts[9].toDouble();

    // Telemetry values
    double velocity    = parts[10].toDouble();
    double temperature = parts[11].toDouble();
    double signal      = parts[12].toDouble();
    double battery     = parts[13].toDouble();

    if (kSerialDebug) {
        qDebug() << "IMU:" << x << y << z
                 << "| Gyro:" << roll << pitch << yaw
                 << "| Baro:" << pressure << altitude
                 << "| Kalman:" << rawAngle << filteredAngle
                 << "| Telemetry:" << velocity << temperature << signal << battery;
    }

    // Broadcast one “sample” event per logical sensor group.
    emit imuDataReceived(x, y, z, roll, pitch, yaw);
    emit kalmanDataReceived(rawAngle, filteredAngle);
    emit baroDataReceived(pressure, altitude);
    emit telemetryDataReceived(velocity, temperature, signal, battery);
}

void SensorDataModel::updateIMU(double x, double y, double z,
                                double roll, double pitch, double yaw)
{
    // Cache latest IMU values and notify QML bindings.
    m_imuX = x;
    m_imuY = y;
    m_imuZ = z;
    m_roll = roll;
    m_pitch = pitch;
    m_yaw = yaw;

    emit imuDataChanged();
}

void SensorDataModel::updateKalman(double rawAngle, double filteredAngle)
{
    // Cache latest angles and notify QML bindings.
    m_rawAngle = rawAngle;
    m_filteredAngle = filteredAngle;

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
