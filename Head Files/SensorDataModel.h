#ifndef SENSORDATAMODEL_H
#define SENSORDATAMODEL_H

#include <QObject>
#include <QString>

class SerialBridge;

/**
 * @brief SensorDataModel
 * Holds the latest parsed sensor values and exposes them to QML via properties.
 */
class SensorDataModel : public QObject {
    Q_OBJECT

public:
    /// Construct a SensorDataModel that listens to lines from the given SerialBridge.
    explicit SensorDataModel(SerialBridge* bridge, QObject* parent = nullptr);

    // IMU - Accelerometer (QML-readable; updated when imuDataChanged() is emitted)
    Q_PROPERTY(double imuX READ imuX NOTIFY imuDataChanged)
    Q_PROPERTY(double imuY READ imuY NOTIFY imuDataChanged)
    Q_PROPERTY(double imuZ READ imuZ NOTIFY imuDataChanged)

    // IMU - Gyroscope
    Q_PROPERTY(double roll READ roll NOTIFY imuDataChanged)
    Q_PROPERTY(double pitch READ pitch NOTIFY imuDataChanged)
    Q_PROPERTY(double yaw READ yaw NOTIFY imuDataChanged)

    // Barometer
    Q_PROPERTY(double pressure READ pressure NOTIFY baroDataChanged)
    Q_PROPERTY(double altitude READ altitude NOTIFY baroDataChanged)

    // Kalman Filter
    Q_PROPERTY(double rawAngle READ rawAngle NOTIFY kalmanDataChanged)
    Q_PROPERTY(double filteredAngle READ filteredAngle NOTIFY kalmanDataChanged)

    // Telemetry
    Q_PROPERTY(double velocity READ velocity NOTIFY telemetryDataChanged)
    Q_PROPERTY(double temperature READ temperature NOTIFY telemetryDataChanged)
    Q_PROPERTY(double signal READ signal NOTIFY telemetryDataChanged)
    Q_PROPERTY(double battery READ battery NOTIFY telemetryDataChanged)

    // Simple getters used by QML properties
    double imuX() const { return m_imuX; }
    double imuY() const { return m_imuY; }
    double imuZ() const { return m_imuZ; }
    double roll() const { return m_roll; }
    double pitch() const { return m_pitch; }
    double yaw() const { return m_yaw; }

    double pressure() const { return m_pressure; }
    double altitude() const { return m_altitude; }

    double rawAngle() const { return m_rawAngle; }
    double filteredAngle() const { return m_filteredAngle; }

    double velocity() const { return m_velocity; }
    double temperature() const { return m_temperature; }
    double signal() const { return m_signal; }
    double battery() const { return m_battery; }

public slots:
    /// Entry point for raw text lines; usually connected to SerialBridge::textReceivedFrom().
    void onLineReceived(const QString& line);

    /// Store IMU values and notify QML that IMU-related data changed.
    void updateIMU(double x, double y, double z,
                   double roll, double pitch, double yaw);

    /// Store Kalman filter angles and notify QML.
    void updateKalman(double rawAngle, double filteredAngle);

    /// Store barometric values and notify QML.
    void updateBaro(double pressure, double altitude);

    /// Store telemetry values and notify QML.
    void updateTelemetry(double velocity, double temperature,
                         double signal, double battery);

signals:
    // NOTIFY signals for QML bindings
    void imuDataChanged();
    void kalmanDataChanged();
    void baroDataChanged();
    void telemetryDataChanged();

    /// Emitted when a line has been parsed into IMU fields.
    void imuDataReceived(double x, double y, double z,
                         double roll, double pitch, double yaw);

    /// Emitted when a line has been parsed into Kalman angles.
    void kalmanDataReceived(double rawAngle, double filteredAngle);

    /// Emitted when a line has been parsed into barometric values.
    void baroDataReceived(double pressure, double altitude);

    /// Emitted when a line has been parsed into telemetry values.
    void telemetryDataReceived(double velocity, double temperature,
                               double signal, double battery);

private:
    // Backing storage for the latest sensor values
    double m_imuX = 0.0;
    double m_imuY = 0.0;
    double m_imuZ = 0.0;
    double m_roll = 0.0;
    double m_pitch = 0.0;
    double m_yaw = 0.0;

    double m_pressure = 0.0;
    double m_altitude = 0.0;

    double m_rawAngle = 0.0;
    double m_filteredAngle = 0.0;

    double m_velocity = 0.0;
    double m_temperature = 0.0;
    double m_signal = 0.0;
    double m_battery = 0.0;

    /// Parse a CSV line into individual sensor values and emit the corresponding *DataReceived signals.
    void parseIncomingData(const QString& line);

    SerialBridge* m_bridge = nullptr;  ///< Non-owning pointer to the serial bridge used as data source.
};

#endif // SENSORDATAMODEL_H
