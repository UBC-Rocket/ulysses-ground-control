#include "DownlinkDecoder.h"
#include "SerialBridge.h"
#include <QDebug>

extern "C" {
    #include "rp/codec.h"
    #include "downlink.pb.h"
}

DownlinkDecoder::DownlinkDecoder(SerialBridge* bridge, QObject* parent)
    : QObject(parent), m_bridge(bridge)
{
    connect(m_bridge, &SerialBridge::binaryReceivedFrom,
            this, &DownlinkDecoder::onBinaryReceived);
}

void DownlinkDecoder::onBinaryReceived(int which, const QByteArray &packet)
{
    Q_UNUSED(which);

    tvr_Downlink downlink = tvr_Downlink_init_zero;

    rp_packet_decode_result_t result = rp_packet_decode(
        reinterpret_cast<const uint8_t*>(packet.constData()),
        static_cast<size_t>(packet.size()),
        tvr_Downlink_fields,
        &downlink
    );

    if (result.status != RP_CODEC_OK) {
        qWarning() << "DownlinkDecoder: decode failed, status =" << result.status
                    << " size =" << packet.size();
        return;
    }

    switch (downlink.which_payload) {
    case tvr_Downlink_telemetry_tag: {
        const tvr_TelemetryState &tel = downlink.payload.telemetry;
        m_telTimestampMs = tel.timestamp_ms;
        m_telFlightState = static_cast<int>(tel.flight_state);
        if (tel.has_position) {
            m_posX = tel.position.x;
            m_posY = tel.position.y;
            m_posZ = tel.position.z;
        }
        if (tel.has_velocity) {
            m_velX = tel.velocity.x;
            m_velY = tel.velocity.y;
            m_velZ = tel.velocity.z;
        }
        if (tel.has_attitude) {
            m_attW = tel.attitude.w;
            m_attX = tel.attitude.x;
            m_attY = tel.attitude.y;
            m_attZ = tel.attitude.z;
        }
        if (tel.has_angular_rate) {
            m_angRateX = tel.angular_rate.x;
            m_angRateY = tel.angular_rate.y;
            m_angRateZ = tel.angular_rate.z;
        }
        m_thrustCmd = tel.thrust_cmd;
        m_gimbalX   = tel.gimbal_x;
        m_gimbalY   = tel.gimbal_y;
        emit telemetryReceived();
        break;
    }
    case tvr_Downlink_status_tag: {
        const tvr_SystemStatus &st = downlink.payload.status;
        m_timestampMs  = st.timestamp_ms;
        m_uptimeMs     = st.uptime_ms;
        m_flightState  = static_cast<int>(st.flight_state);
        m_accelOk      = st.accel_ok;
        m_gyroOk       = st.gyro_ok;
        m_baro1Ok      = st.baro1_ok;
        m_baro2Ok      = st.baro2_ok;
        m_gpsConnected = st.gps_connected;
        m_radioTxCount = st.radio_tx_count;
        m_radioRxCount = st.radio_rx_count;
        m_cmdRxCount   = st.cmd_rx_count;
        emit statusReceived();
        break;
    }
    default:
        qWarning() << "DownlinkDecoder: unknown payload tag" << downlink.which_payload;
        break;
    }
}
