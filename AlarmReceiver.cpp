#include "AlarmReceiver.h"
#include "SerialBridge.h"

AlarmReceiver::AlarmReceiver(SerialBridge* bridge, QObject* parent)
    : QObject(parent), m_bridge(bridge)
{
    if (m_bridge) {
        connect(m_bridge, &SerialBridge::rxTextReceived,
                this, &AlarmReceiver::onLineReceived);
    }
}

void AlarmReceiver::onLineReceived(const QString& line) {
    classifyAndEmit(line); // delegate to regex-based classifier
}

void AlarmReceiver::classifyAndEmit(const QString& line) {
    // Priority: error > warning > success (first match wins).
    if (m_reErr.match(line).hasMatch())   { emit rxError(line);   return; }
    if (m_reWarn.match(line).hasMatch())  { emit rxWarning(line); return; }
    if (m_reSucc.match(line).hasMatch())  { emit rxSuccess(line); return; }
}


