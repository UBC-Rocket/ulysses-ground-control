#include "CommandSender.h"
#include "SerialBridge.h"
#include <QTimer>

CommandSender::CommandSender(SerialBridge* bridge, QObject* parent)
    : m_bridge(bridge), QObject(parent)
{
    setupPeriodicTimer(Qt::PreciseTimer);
}

bool CommandSender::sendCode(const QString& code) {
    if (!m_bridge) {
        emit errorOccurred("No bridge");   // guard: cannot send without a bound SerialBridge
        return false;
    }
    bool ok = m_bridge->sendText(code);    // delegate actual TX to SerialBridge (returns success/failure)

    if (ok) {
        emit messageSent(code);            // notify UI that the exact payload was dispatched
    }
    else {
        emit errorOccurred("Failed to send code"); // bubble up a simple, user-facing error
    }
    return ok;                              // propagate result to QML/caller for further handling
}

void CommandSender::setupPeriodicTimer(Qt::TimerType type)
{
    m_timer.setTimerType(type);
    m_timer.disconnect(this);
    connect(&m_timer, &QTimer::timeout, this, &CommandSender::onPeriodicTimeout);
}

void CommandSender::onPeriodicTimeout()
{
    if (!m_bridge) {
        emit errorOccurred("No bridge");
        return;
    }
    const bool ok = m_bridge->sendText(m_periodicPayload);
    if (ok) {
        emit messageSent(m_periodicPayload);
    }
    else {
        emit errorOccurred("Periodic send failed");
    }
}

void CommandSender::startPeriodic(const QString& code, int hz) {
    if (hz <= 0) {
        emit errorOccurred("Hz must be > 0");
        return;
    }
    m_periodicPayload = code;
    m_timer.start(1000 / hz);
}

void CommandSender::stopPeriodic() {
    m_timer.stop();
}







