#ifndef SENSORDATAMODEL_H
#define SENSORDATAMODEL_H

#include <QObject>

/**
 * @brief SensorDataModel
 * Stores the latest sensor readings and exposes them to QML.
 * This is like a "database" that holds the current values.
 */
class SensorDataModel : public QObject {
    Q_OBJECT
    
    // These Q_PROPERTY lines make the variables readable from QML
    // QML can access them like: sensorData.imuX
    
    // IMU - Accelerometer
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

public:
    explicit SensorDataModel(QObject* parent = nullptr);
    
    // Getter functions
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
    // These functions are called when new data arrives
    void updateIMU(double x, double y, double z, double roll, double pitch, double yaw);
    void updateKalman(double rawAngle, double filteredAngle);
    void updateBaro(double pressure, double altitude);
    void updateTelemetry(double velocity, double temperature, double signal, double battery);

signals:
    // Tells QML to update changes
    void imuDataChanged();
    void kalmanDataChanged();
    void baroDataChanged();
    void telemetryDataChanged();

private:
    // Variable storage
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
};

#endif // SENSORDATAMODEL_H