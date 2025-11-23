#include "CommandSender.h"
#include "SerialBridge.h"
#include <QTimer>

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
