#include "CommandSender.h"
#include "SerialBridge.h"

CommandSender::CommandSender(SerialBridge* bridge, QObject* parent)
    : m_bridge(bridge), QObject(parent) {}

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




