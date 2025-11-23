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

    // Barometer
    Q_PROPERTY(double pressure READ pressure NOTIFY baroDataChanged)
    Q_PROPERTY(double altitude READ altitude NOTIFY baroDataChanged)

    // Kalman Filter (separate X/Y, raw/filtered)
    Q_PROPERTY(double rawAngleX READ rawAngleX NOTIFY kalmanDataChanged)
    Q_PROPERTY(double filteredAngleX READ filteredAngleX NOTIFY kalmanDataChanged)
    Q_PROPERTY(double rawAngleY READ rawAngleY NOTIFY kalmanDataChanged)
    Q_PROPERTY(double filteredAngleY READ filteredAngleY NOTIFY kalmanDataChanged)

    // Telemetry
    Q_PROPERTY(double velocity READ velocity NOTIFY telemetryDataChanged)
    Q_PROPERTY(double temperature READ temperature NOTIFY telemetryDataChanged)
    Q_PROPERTY(double signal READ signal NOTIFY telemetryDataChanged)
    Q_PROPERTY(double battery READ battery NOTIFY telemetryDataChanged)

    // Simple getters used by QML properties
    double pressure() const { return m_pressure; }
    double altitude() const { return m_altitude; }

    double rawAngleX() const { return m_rawAngleX; }
    double filteredAngleX() const { return m_filteredAngleX; }
    double rawAngleY() const { return m_rawAngleY; }
    double filteredAngleY() const { return m_filteredAngleY; }

    double velocity() const { return m_velocity; }
    double temperature() const { return m_temperature; }
    double signal() const { return m_signal; }
    double battery() const { return m_battery; }

public slots:
    /// Entry point for raw text lines; usually connected to SerialBridge::textReceivedFrom().
    void onLineReceived(const QString& line);

    /// Store Kalman filter angles and notify QML.
    void updateKalman(double rawAngleX, double filteredAngleX,
                      double rawAngleY, double filteredAngleY);

    /// Store barometric values and notify QML.
    void updateBaro(double pressure, double altitude);

    /// Store telemetry values and notify QML.
    void updateTelemetry(double velocity, double temperature,
                         double signal, double battery);

signals:
    // NOTIFY signals for QML bindings
    void kalmanDataChanged();
    void baroDataChanged();
    void telemetryDataChanged();

private:
    // Backing storage for the latest sensor values
    double m_pressure = 0.0;
    double m_altitude = 0.0;

    double m_rawAngleX = 0.0;
    double m_filteredAngleX = 0.0;
    double m_rawAngleY = 0.0;
    double m_filteredAngleY = 0.0;

    double m_velocity = 0.0;
    double m_temperature = 0.0;
    double m_signal = 0.0;
    double m_battery = 0.0;

    /// Parse a CSV line into individual sensor values and update stored properties.
    void parseIncomingData(const QString& line);

    SerialBridge* m_bridge = nullptr;  ///< Non-owning pointer to the serial bridge used as data source.
};

#endif // SENSORDATAMODEL_H
