#ifndef COMMANDSENDER_H
#define COMMANDSENDER_H

#pragma once
#include <QObject>

class SerialBridge;

class CommandSender : public QObject {
    Q_OBJECT

public:
    explicit CommandSender(SerialBridge* bridge, QObject* parent = nullptr);

    /**
     * @brief sendCode
     * Sends a command string through the bound SerialBridge (typically out the TX port).
     * Implementations commonly validate/normalize @p code, then emit messageSent()/errorOccurred().
     * @param code Command payload to transmit (format decided by your application/protocol).
     * @return true on successful dispatch; false if bridge is null, TX not open, or validation fails.
     */
    Q_INVOKABLE bool sendCode(const QString& code);

signals:
    // -----------------------
    // App-level signals
    // -----------------------

    /**
     * @brief messageSent
     * Emitted after a command is successfully handed off for transmission (echoes the payload).
     */
    void messageSent(const QString payload);

    /**
     * @brief errorOccurred
     * Emitted when sending fails (e.g., no bridge, port closed, or other validation/runtime error).
     */
    void errorOccurred(const QString error);

public slots:
    /**
     * @brief setBridge
     * Late-bind or swap the target SerialBridge instance at runtime; object is not owned by CommandSender.
     * @param bridge The transport to use for subsequent sendCode() calls.
     */
    void setBridge(SerialBridge* bridge) {m_bridge = bridge;}

private:
    SerialBridge* m_bridge = nullptr; ///< Non-owning pointer to the transport layer; lifetime managed externally.
};

#endif // COMMANDSENDER_H
