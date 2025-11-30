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
