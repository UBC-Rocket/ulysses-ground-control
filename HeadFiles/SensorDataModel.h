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

    // Barometer / position
    Q_PROPERTY(double pressure READ pressure NOTIFY baroDataChanged)
    Q_PROPERTY(double altitude READ altitude NOTIFY baroDataChanged)
    Q_PROPERTY(double posX     READ posX     NOTIFY baroDataChanged)
    Q_PROPERTY(double posY     READ posY     NOTIFY baroDataChanged)

    // Kalman Filter — raw = angular rate (deg/s), filtered = Euler angle (deg)
    Q_PROPERTY(double rawAngleX      READ rawAngleX      NOTIFY kalmanDataChanged)
    Q_PROPERTY(double filteredAngleX READ filteredAngleX NOTIFY kalmanDataChanged)
    Q_PROPERTY(double rawAngleY      READ rawAngleY      NOTIFY kalmanDataChanged)
    Q_PROPERTY(double filteredAngleY READ filteredAngleY NOTIFY kalmanDataChanged)
    Q_PROPERTY(double rawAngleZ      READ rawAngleZ      NOTIFY kalmanDataChanged)
    Q_PROPERTY(double filteredAngleZ READ filteredAngleZ NOTIFY kalmanDataChanged)

    // Engine outputs
    Q_PROPERTY(double thrustCmd READ thrustCmd NOTIFY engineDataChanged)
    Q_PROPERTY(double gimbalX   READ gimbalX   NOTIFY engineDataChanged)
    Q_PROPERTY(double gimbalY   READ gimbalY   NOTIFY engineDataChanged)

    // Telemetry / link stats
    Q_PROPERTY(double velocity     READ velocity     NOTIFY telemetryDataChanged)
    Q_PROPERTY(double temperature  READ temperature  NOTIFY telemetryDataChanged)
    Q_PROPERTY(double signal       READ signal       NOTIFY telemetryDataChanged)
    Q_PROPERTY(double radioTxCount READ radioTxCount NOTIFY telemetryDataChanged)

    // Simple getters used by QML properties
    double pressure() const { return m_pressure; }
    double altitude() const { return m_altitude; }
    double posX()     const { return m_posX; }
    double posY()     const { return m_posY; }

    double rawAngleX()      const { return m_rawAngleX; }
    double filteredAngleX() const { return m_filteredAngleX; }
    double rawAngleY()      const { return m_rawAngleY; }
    double filteredAngleY() const { return m_filteredAngleY; }
    double rawAngleZ()      const { return m_rawAngleZ; }
    double filteredAngleZ() const { return m_filteredAngleZ; }

    double thrustCmd() const { return m_thrustCmd; }
    double gimbalX()   const { return m_gimbalX; }
    double gimbalY()   const { return m_gimbalY; }

    double velocity()     const { return m_velocity; }
    double temperature()  const { return m_temperature; }
    double signal()       const { return m_signal; }
    double radioTxCount() const { return m_radioTxCount; }

public slots:
    /// Entry point for raw text lines; usually connected to SerialBridge::textReceivedFrom().
    void onLineReceived(const QString& line);

    /// Entry point for binary COBS packets; decode Downlink and update model.
    void onBinaryPacketReceived(int which, const QByteArray& packet);

    /// Store Kalman filter angles and notify QML.
    void updateKalman(double rawAngleX, double filteredAngleX,
                      double rawAngleY, double filteredAngleY,
                      double rawAngleZ, double filteredAngleZ);

    /// Store barometric/position values and notify QML.
    void updateBaro(double pressure, double altitude, double posX = 0.0, double posY = 0.0);

    /// Store engine outputs and notify QML.
    void updateEngine(double thrustCmd, double gimbalX, double gimbalY);

    /// Store telemetry values and notify QML.
    void updateTelemetry(double velocity, double temperature,
                         double signal, double radioTxCount);

signals:
    // NOTIFY signals for QML bindings
    void kalmanDataChanged();
    void baroDataChanged();
    void engineDataChanged();
    void telemetryDataChanged();

private:
    // Backing storage for the latest sensor values
    double m_pressure = 0.0;
    double m_altitude = 0.0;
    double m_posX     = 0.0;
    double m_posY     = 0.0;

    double m_rawAngleX      = 0.0;
    double m_filteredAngleX = 0.0;
    double m_rawAngleY      = 0.0;
    double m_filteredAngleY = 0.0;
    double m_rawAngleZ      = 0.0;
    double m_filteredAngleZ = 0.0;

    double m_thrustCmd = 0.0;
    double m_gimbalX   = 0.0;
    double m_gimbalY   = 0.0;

    double m_velocity     = 0.0;
    double m_temperature  = 0.0;
    double m_signal       = 0.0;
    double m_radioTxCount = 0.0;

    /// Parse a CSV line into individual sensor values and update stored properties.
    void parseIncomingData(const QString& line);

    /// Update model from decoded Downlink (TelemetryState or SystemStatus).
    void applyDownlink(int which, const void* downlinkStruct);

    SerialBridge* m_bridge = nullptr;  ///< Non-owning pointer to the serial bridge used as data source.
};

#endif // SENSORDATAMODEL_H
