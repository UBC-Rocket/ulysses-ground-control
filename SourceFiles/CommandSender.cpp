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
    
    // 1. Create FlightCommand message
    tvr_flight_command_t cmd = TVR_FLIGHT_COMMAND_INIT_ZERO;
    cmd.which_payload = TVR_FLIGHT_COMMAND_STATE_CMD_TAG; // set oneof
    cmd.payload.state_cmd.type = (tvr_state_command_type_t)commandType; // set type

    
    // 2. Encode to COBS packet
    uint8_t packet[300];
    rp_packet_encode_result_t result = rp_packet_encode(
        packet,
        sizeof(packet),
        TVR_FLIGHT_COMMAND_FIELDS,
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
    // TODO: handle sending the PID values

    if (!validWhich(which)) {
        emit errorOccurred("which must be 1 or 2");
        return false;
    }
    
    if (!m_bridge) {
        emit errorOccurred("No bridge");
        return false;
    }

    tvr_set_pid_t pid = TVR_SET_PID_INIT_ZERO;

    pid.x1 = (float)PIDValues[0].toDouble();
    pid.x2 = (float)PIDValues[1].toDouble();
    pid.x3 = (float)PIDValues[2].toDouble();
    pid.x4 = (float)PIDValues[3].toDouble();
    pid.x5 = (float)PIDValues[4].toDouble();
    pid.x6 = (float)PIDValues[5].toDouble();
    pid.x7 = (float)PIDValues[6].toDouble();
    pid.x8 = (float)PIDValues[7].toDouble();
    pid.x9 = (float)PIDValues[8].toDouble();

    uint8_t packet[300];
    rp_packet_encode_result_t result = rp_packet_encode(
        packet,
        sizeof(packet),
        TVR_SET_PID_FIELDS,
        &pid
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
    
    emit messageSent("setPID sent");
    return true;

}
