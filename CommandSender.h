#ifndef COMMANDSENDER_H
#define COMMANDSENDER_H

#include <QObject>
#include <QTimer>

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

    /*
     * the methods to send a 50Hz string signal for tests.
     * (not a part of GCS)
     */
    Q_INVOKABLE void startPeriodic(const QString& code, int hz = 50);
    Q_INVOKABLE void stopPeriodic();
    Q_INVOKABLE bool isPeriodicRunning() const { return m_timer.isActive(); }

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

private slots:
    /**
     * @brief onPeriodicTimeout
     * Internal slot fired by @ref m_timer at the configured rate.
     * Sends @ref m_periodicPayload via sendCode()/bridge and handles failures.
     */
    void onPeriodicTimeout();

private:
    /**
     * @brief setupPeriodicTimer
     * Configures @ref m_timer with the desired @p type (default PreciseTimer),
     * connects its timeout() to @ref onPeriodicTimeout, and leaves it stopped.
     * Call m_timer.start(interval_ms) elsewhere to begin ticking.
     */
    void setupPeriodicTimer(Qt::TimerType type = Qt::PreciseTimer);

    SerialBridge* m_bridge = nullptr; ///< Non-owning transport pointer; lifetime managed externally.
    QTimer m_timer;                   ///< Drives periodic sends when active.
    QString m_periodicPayload;        ///< The command payload dispatched on each timer tick.

};

#endif // COMMANDSENDER_H
