#include "AlarmReceiver.h"
#include "SerialBridge.h"

AlarmReceiver::AlarmReceiver(SerialBridge* bridge, QObject* parent)
    : QObject(parent)
    , m_bridge(bridge)
{
    if (!m_bridge)
        return; // Nothing to hook into if bridge is null.

    // Single connection: classify only the "active" RX source based on connection state.
    QObject::connect(
        m_bridge,
        &SerialBridge::textReceivedFrom,
        this,
        [this](int which, const QString &line) {
            if (!m_bridge)
                return; // Bridge was cleared or destroyed.

            const bool p1 = m_bridge->isConnected(1);
            const bool p2 = m_bridge->isConnected(2);

            bool listen = false;

            if (p1 && p2) {
                // Both ports connected → treat P1 as the canonical source for alarms.
                listen = (which == 1);
            } else if (p1 || p2) {
                // Exactly one port connected → listen only to that one.
                listen = m_bridge->isConnected(which);
            } else {
                // No ports connected → ignore everything.
                listen = false;
            }

            if (listen) {
                onLineReceived(line); // Forward to classifier only if this port is the chosen source.
            }
        }
        );
}

void AlarmReceiver::onLineReceived(const QString& line)
{
    classifyAndEmit(line);
}

void AlarmReceiver::classifyAndEmit(const QString& line)
{
    // Priority: error → warning → success. First match wins; rest are skipped.
    if (m_reErr.match(line).hasMatch()) {
        emit rxError(line);
        return;
    }
    if (m_reWarn.match(line).hasMatch()) {
        emit rxWarning(line);
        return;
    }
    if (m_reSucc.match(line).hasMatch()) {
        emit rxSuccess(line);
        return;
    }
    // No match → silent ignore.
}

