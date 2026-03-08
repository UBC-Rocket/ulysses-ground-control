#ifndef SENSORDATAMODEL_H
#define SENSORDATAMODEL_H

#include <QObject>
#include <QString>

class SerialBridge;

/**
 * @brief SensorDataModel
 * Holds the latest parsed sensor values and exposes them to QML via properties.
 * Decodes both TelemetryState (10Hz) and SystemStatus (1Hz) from protobuf downlink.
 */
class SensorDataModel : public QObject {
    Q_OBJECT

public:
    explicit SensorDataModel(SerialBridge* bridge, QObject* parent = nullptr);

    // Position
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

    // Telemetry
    Q_PROPERTY(double velocity READ velocity NOTIFY telemetryDataChanged)

    // Raw packet log (hex dump of every received binary packet)
    Q_PROPERTY(QString rawPacketLog READ rawPacketLog NOTIFY rawPacketLogChanged)

    // SystemStatus properties
    Q_PROPERTY(int     flightState   READ flightState   NOTIFY statusReceived)
    Q_PROPERTY(quint32 uptimeMs      READ uptimeMs      NOTIFY statusReceived)
    Q_PROPERTY(bool    accelOk       READ accelOk       NOTIFY statusReceived)
    Q_PROPERTY(bool    gyroOk        READ gyroOk        NOTIFY statusReceived)
    Q_PROPERTY(bool    baro1Ok       READ baro1Ok       NOTIFY statusReceived)
    Q_PROPERTY(bool    baro2Ok       READ baro2Ok       NOTIFY statusReceived)
    Q_PROPERTY(bool    gpsConnected  READ gpsConnected  NOTIFY statusReceived)
    Q_PROPERTY(quint32 radioRxCount  READ radioRxCount  NOTIFY statusReceived)
    Q_PROPERTY(quint32 radioTxCount  READ radioTxCount  NOTIFY statusReceived)
    Q_PROPERTY(quint32 cmdRxCount    READ cmdRxCount    NOTIFY statusReceived)

    // Simple getters used by QML properties
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

    double velocity() const { return m_velocity; }

    int     flightState()  const { return m_flightState; }
    quint32 uptimeMs()     const { return m_uptimeMs; }
    bool    accelOk()      const { return m_accelOk; }
    bool    gyroOk()       const { return m_gyroOk; }
    bool    baro1Ok()      const { return m_baro1Ok; }
    bool    baro2Ok()      const { return m_baro2Ok; }
    bool    gpsConnected() const { return m_gpsConnected; }
    quint32 radioRxCount() const { return m_radioRxCount; }
    quint32 radioTxCount() const { return m_radioTxCount; }
    quint32 cmdRxCount()   const { return m_cmdRxCount; }

    QString rawPacketLog() const { return m_rawPacketLog; }
    Q_INVOKABLE void clearRawPacketLog();

public slots:
    /// Entry point for binary COBS packets; decode Downlink and update model.
    void onBinaryPacketReceived(int which, const QByteArray& packet);

    /// Store Kalman filter angles and notify QML.
    void updateKalman(double rawAngleX, double filteredAngleX,
                      double rawAngleY, double filteredAngleY,
                      double rawAngleZ, double filteredAngleZ);

    /// Store position values and notify QML.
    void updatePosition(double altitude, double posX = 0.0, double posY = 0.0);

    /// Store engine outputs and notify QML.
    void updateEngine(double thrustCmd, double gimbalX, double gimbalY);

    /// Store telemetry speed value and notify QML.
    void updateTelemetry(double velocity);

signals:
    // NOTIFY signals for QML bindings
    void kalmanDataChanged();
    void baroDataChanged();
    void engineDataChanged();
    void telemetryDataChanged();
    void statusReceived();
    void rawPacketLogChanged();

private:
    // Backing storage for the latest sensor values
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

    double m_velocity = 0.0;

    // SystemStatus state
    int     m_flightState  = 0;
    quint32 m_uptimeMs     = 0;
    bool    m_accelOk      = false;
    bool    m_gyroOk       = false;
    bool    m_baro1Ok      = false;
    bool    m_baro2Ok      = false;
    bool    m_gpsConnected = false;
    quint32 m_radioRxCount = 0;
    quint32 m_radioTxCount = 0;
    quint32 m_cmdRxCount   = 0;

    QString m_rawPacketLog;

    /// Update model from decoded Downlink (TelemetryState or SystemStatus).
    void applyDownlink(int which, const void* downlinkStruct);

    SerialBridge* m_bridge = nullptr;
};

#endif // SENSORDATAMODEL_H
