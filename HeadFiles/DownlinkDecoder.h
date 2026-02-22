#ifndef DOWNLINKDECODER_H
#define DOWNLINKDECODER_H

#include <QObject>
#include <cstdint>

class SerialBridge;

class DownlinkDecoder : public QObject {
    Q_OBJECT

    // --- SystemStatus properties ---
    Q_PROPERTY(quint32 timestampMs READ timestampMs NOTIFY statusReceived)
    Q_PROPERTY(quint32 uptimeMs READ uptimeMs NOTIFY statusReceived)
    Q_PROPERTY(int flightState READ flightState NOTIFY statusReceived)
    Q_PROPERTY(bool accelOk READ accelOk NOTIFY statusReceived)
    Q_PROPERTY(bool gyroOk READ gyroOk NOTIFY statusReceived)
    Q_PROPERTY(bool baro1Ok READ baro1Ok NOTIFY statusReceived)
    Q_PROPERTY(bool baro2Ok READ baro2Ok NOTIFY statusReceived)
    Q_PROPERTY(bool gpsConnected READ gpsConnected NOTIFY statusReceived)
    Q_PROPERTY(quint32 radioTxCount READ radioTxCount NOTIFY statusReceived)
    Q_PROPERTY(quint32 radioRxCount READ radioRxCount NOTIFY statusReceived)
    Q_PROPERTY(quint32 cmdRxCount READ cmdRxCount NOTIFY statusReceived)

    // --- TelemetryState properties ---
    Q_PROPERTY(quint32 telTimestampMs READ telTimestampMs NOTIFY telemetryReceived)
    Q_PROPERTY(int telFlightState READ telFlightState NOTIFY telemetryReceived)
    Q_PROPERTY(float posX READ posX NOTIFY telemetryReceived)
    Q_PROPERTY(float posY READ posY NOTIFY telemetryReceived)
    Q_PROPERTY(float posZ READ posZ NOTIFY telemetryReceived)
    Q_PROPERTY(float velX READ velX NOTIFY telemetryReceived)
    Q_PROPERTY(float velY READ velY NOTIFY telemetryReceived)
    Q_PROPERTY(float velZ READ velZ NOTIFY telemetryReceived)
    Q_PROPERTY(float attW READ attW NOTIFY telemetryReceived)
    Q_PROPERTY(float attX READ attX NOTIFY telemetryReceived)
    Q_PROPERTY(float attY READ attY NOTIFY telemetryReceived)
    Q_PROPERTY(float attZ READ attZ NOTIFY telemetryReceived)
    Q_PROPERTY(float angRateX READ angRateX NOTIFY telemetryReceived)
    Q_PROPERTY(float angRateY READ angRateY NOTIFY telemetryReceived)
    Q_PROPERTY(float angRateZ READ angRateZ NOTIFY telemetryReceived)
    Q_PROPERTY(float thrustCmd READ thrustCmd NOTIFY telemetryReceived)
    Q_PROPERTY(float gimbalX READ gimbalX NOTIFY telemetryReceived)
    Q_PROPERTY(float gimbalY READ gimbalY NOTIFY telemetryReceived)

public:
    explicit DownlinkDecoder(SerialBridge* bridge, QObject* parent = nullptr);

    // SystemStatus getters
    quint32 timestampMs()   const { return m_timestampMs; }
    quint32 uptimeMs()      const { return m_uptimeMs; }
    int     flightState()   const { return m_flightState; }
    bool    accelOk()       const { return m_accelOk; }
    bool    gyroOk()        const { return m_gyroOk; }
    bool    baro1Ok()       const { return m_baro1Ok; }
    bool    baro2Ok()       const { return m_baro2Ok; }
    bool    gpsConnected()  const { return m_gpsConnected; }
    quint32 radioTxCount()  const { return m_radioTxCount; }
    quint32 radioRxCount()  const { return m_radioRxCount; }
    quint32 cmdRxCount()    const { return m_cmdRxCount; }

    // TelemetryState getters
    quint32 telTimestampMs() const { return m_telTimestampMs; }
    int     telFlightState() const { return m_telFlightState; }
    float   posX()      const { return m_posX; }
    float   posY()      const { return m_posY; }
    float   posZ()      const { return m_posZ; }
    float   velX()      const { return m_velX; }
    float   velY()      const { return m_velY; }
    float   velZ()      const { return m_velZ; }
    float   attW()      const { return m_attW; }
    float   attX()      const { return m_attX; }
    float   attY()      const { return m_attY; }
    float   attZ()      const { return m_attZ; }
    float   angRateX()  const { return m_angRateX; }
    float   angRateY()  const { return m_angRateY; }
    float   angRateZ()  const { return m_angRateZ; }
    float   thrustCmd() const { return m_thrustCmd; }
    float   gimbalX()   const { return m_gimbalX; }
    float   gimbalY()   const { return m_gimbalY; }

signals:
    void telemetryReceived();
    void statusReceived();

private slots:
    void onBinaryReceived(int which, const QByteArray &packet);

private:
    SerialBridge* m_bridge = nullptr;

    // SystemStatus state
    quint32 m_timestampMs  = 0;
    quint32 m_uptimeMs     = 0;
    int     m_flightState  = 0;
    bool    m_accelOk      = false;
    bool    m_gyroOk       = false;
    bool    m_baro1Ok      = false;
    bool    m_baro2Ok      = false;
    bool    m_gpsConnected = false;
    quint32 m_radioTxCount = 0;
    quint32 m_radioRxCount = 0;
    quint32 m_cmdRxCount   = 0;

    // TelemetryState state
    quint32 m_telTimestampMs = 0;
    int     m_telFlightState = 0;
    float   m_posX     = 0.0f;
    float   m_posY     = 0.0f;
    float   m_posZ     = 0.0f;
    float   m_velX     = 0.0f;
    float   m_velY     = 0.0f;
    float   m_velZ     = 0.0f;
    float   m_attW     = 1.0f;
    float   m_attX     = 0.0f;
    float   m_attY     = 0.0f;
    float   m_attZ     = 0.0f;
    float   m_angRateX = 0.0f;
    float   m_angRateY = 0.0f;
    float   m_angRateZ = 0.0f;
    float   m_thrustCmd = 0.0f;
    float   m_gimbalX  = 0.0f;
    float   m_gimbalY  = 0.0f;
};

#endif // DOWNLINKDECODER_H
