#include "CommandSender.h"
#include "SerialBridge.h"
#include <QTimer>
extern "C" {
    #include "rp/codec.h"
    #include "command.pb.h"
}


CommandSender::CommandSender(SerialBridge* bridge, QObject* parent)
    : m_bridge(bridge), QObject(parent)
{
    // Channel 1 periodic sender: fires at fixed rate, sends cached payload if bridge exists.
    m_ch1.timer.setTimerType(Qt::PreciseTimer);
    connect(&m_ch1.timer, &QTimer::timeout, this, [this]() {
        if (!m_bridge) { emit errorOccurred("No Bridge"); return; }
        if (!m_ch1.payload.isEmpty()) {
            if (m_bridge->sendText(1, m_ch1.payload))
                emit messageSent(m_ch1.payload);
            else
                emit errorOccurred("Periodic send failed (P1)");
        }
    });


    // Channel 2 periodic sender: same idea but for channel 2 payload.
    m_ch2.timer.setTimerType(Qt::PreciseTimer);
    connect(&m_ch2.timer, &QTimer::timeout, this, [this]() {
        if (!m_bridge) { emit errorOccurred("No Bridge"); return; }
        if (!m_ch2.payload.isEmpty()) {
            if (m_bridge->sendText(1, m_ch2.payload))
                emit messageSent(m_ch2.payload);
            else
                emit errorOccurred("Periodic send failed (P1)");
        }
    });
}


bool CommandSender::sendCode(int which, const QString& code) {
    if (!validWhich(which)) {
        emit errorOccurred("which must be 1 or 2");
        return false;
    }


    if (!m_bridge) {
        emit errorOccurred("No bridge");   // Cannot send without a transport.
        return false;
    }


    // Delegate the actual serial write to SerialBridge.
    bool ok = m_bridge->sendText(which, code);


    if (ok) {
        emit messageSent(code);            // Notify listeners what was sent.
    } else {
        emit errorOccurred("Failed to send code");
    }
    return ok;                             // Let caller know if it worked.
}


void CommandSender::startPeriodic(int which, const QString& code, int hz) {
    if (!validWhich(which)) {
        emit errorOccurred("which must be 1 or 2");
        return;
    }


    if (hz <= 0) {
        emit errorOccurred("Hz must be > 0");
        return;
    }


    // Store payload and frequency, then arm the channel timer.
    auto& c = chan(which);
    c.payload = code;
    c.hz = hz;
    c.timer.start(1000 / hz);             // Simple ms interval: 1000ms / Hz.
}


void CommandSender::stopPeriodic(int which) {
    if (!validWhich(which)) {
        emit errorOccurred("which must be 1 or 2");
        return;
    }


    // Just stop the underlying QTimer for that channel.
    chan(which).timer.stop();
}


bool CommandSender::isPeriodicRunning(int which) const {
    if (!validWhich(which))
        return false;


    return chan(which).timer.isActive();  // True if the periodic timer is currently running.
}


bool CommandSender::sendFlightCommand(int which, int commandType) {
    if (!validWhich(which)) {
        emit errorOccurred("which must be 1 or 2");
        return false;
    }
   
    if (!m_bridge) {
        emit errorOccurred("No bridge");
        return false;
    }

    tvr_FlightCommand cmd = tvr_FlightCommand_init_zero;
    cmd.which_payload = tvr_FlightCommand_state_cmd_tag;  // Set oneof
    cmd.payload.state_cmd.type = (tvr_StateCommand_Type)commandType;  // Set type

    uint8_t packet[300];
    rp_packet_encode_result_t result = rp_packet_encode( 
        packet,
        sizeof(packet),
        tvr_FlightCommand_fields,
        &cmd
    );

    if (result.status != RP_CODEC_OK) {
        emit errorOccurred("Failed to encode packet");
        return false;
    }

    // 3. Send binary packet
    QByteArray data(reinterpret_cast<const char*>(packet), result.written);

    if (!m_bridge->sendBinary(which, data)) {
        emit errorOccurred("Failed to send binary packet");
        return false;
    }

    emit messageSent(QString("FlightCommand %1").arg(commandType));
    return true;
   
}


bool CommandSender::sendPIDValues(int which, const QVariantList& PIDValues) {
    if (!validWhich(which)) {
        emit errorOccurred("which must be 1 or 2");
        return false;
    }
   
    if (!m_bridge) {
        emit errorOccurred("No bridge");
        return false;
    }

    if (PIDValues.size() < 9) {
        emit errorOccurred("PIDValues must contain 9 entries");
        return false;
    }

    tvr_SetPidGains pid = tvr_SetPidGains_init_zero;
    pid.has_attitude_kp = true;
    pid.attitude_kp.x = static_cast<float>(PIDValues[0].toDouble());
    pid.attitude_kp.y = static_cast<float>(PIDValues[1].toDouble());
    pid.attitude_kp.z = static_cast<float>(PIDValues[2].toDouble());

    pid.has_attitude_kd = true;
    pid.attitude_kd.x = static_cast<float>(PIDValues[3].toDouble());
    pid.attitude_kd.y = static_cast<float>(PIDValues[4].toDouble());
    pid.attitude_kd.z = static_cast<float>(PIDValues[5].toDouble());

    pid.z_kp = static_cast<float>(PIDValues[6].toDouble());
    pid.z_ki = static_cast<float>(PIDValues[7].toDouble());
    pid.z_kd = static_cast<float>(PIDValues[8].toDouble());
    pid.z_integral_limit = 0.0f;

    tvr_FlightCommand cmd = tvr_FlightCommand_init_zero;
    cmd.which_payload = tvr_FlightCommand_set_pid_gains_tag;
    cmd.payload.set_pid_gains = pid;

    uint8_t packet[300];
    rp_packet_encode_result_t result = rp_packet_encode(
        packet,
        sizeof(packet),
        tvr_FlightCommand_fields,
        &cmd
    );


    if (result.status != RP_CODEC_OK) {
        emit errorOccurred("Failed to encode packet");
        return false;
    }


    QByteArray data(reinterpret_cast<const char*>(packet), result.written);
   
    if (!m_bridge->sendBinary(which, data)) {
        emit errorOccurred("Failed to send binary packet");
        return false;
    }
   
    emit messageSent("SetPidGains sent");
    return true;

}



