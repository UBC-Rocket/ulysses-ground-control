#ifndef SERIALBRIDGE_H
#define SERIALBRIDGE_H

#pragma once
#include <QObject>
#include <QSerialPort>
#include <QSerialPortInfo>
#include <QTimer>

class SerialBridge : public QObject {
    Q_OBJECT

public:
    /**
     * @brief SerialBridge constructor
     * Creates the bridge object and (in .cpp) wires up serial signals and does initial refreshPorts().
     */
    explicit SerialBridge(QObject* parent = nullptr);

    // -----------------------
    // QML-callable API
    // -----------------------

    /// Rescan system serial ports and update the cached port list (ports()).
    Q_INVOKABLE void refreshPorts();

    /// Open port 1 or 2 with the given name/baud; returns true on success.
    Q_INVOKABLE bool connectPort(int which, const QString& name, int baudRate);

    /// Close port 1 or 2 if open and clean up handlers.
    Q_INVOKABLE void disconnectPort(int which);

    /// Set which port index is used as the TX source; emits txToChanged() on success.
    Q_INVOKABLE bool setTxTo(int which);

    /// Set which port index is used as the RX source; emits rxFromChanged() on success.
    Q_INVOKABLE bool setRxFrom(int which);

    /// Send a line of text out through the selected port (1 or 2); returns true on success.
    Q_INVOKABLE bool sendText(int which, const QString& text);

    // -----------------------
    // Property getters
    // -----------------------

    /// Return the current list of available OS serial port names.
    Q_INVOKABLE QStringList ports() const { return m_ports; }

    /// Return true if the given port (1 or 2) is currently open.
    Q_INVOKABLE bool isConnected(int which) const {
        return (which == 1) ? m_p1.isOpen() : m_p2.isOpen();
    }

    /// Return the OS name of the given port (empty if closed or unset).
    Q_INVOKABLE QString portName(int which) const {
        return (which == 1) ? m_p1.portName() : m_p2.portName();
    }

    /// Return the current baud rate for the given port.
    Q_INVOKABLE int baudRate(int which) const {
        return (which == 1) ? m_p1.baudRate() : m_p2.baudRate();
    }

signals:
    // -----------------------
    // Property/Model change notifications (for QML bindings)
    // -----------------------

    /// Emitted when the available port list changes after a refreshPorts() call.
    void portsChanged();

    /// Emitted whenever port 1 or 2 opens or closes.
    void connectedChanged(int which, bool connected);

    /// Emitted when the baud rate of port 1 or 2 changes.
    void baudChanged(int which);

    /// Emitted when the port name of port 1 or 2 changes.
    void portNameChanged(int which);

    /// Emitted when the selected port is open but does not look like an RFD radio modem.
    void butNotRadioModem(int which);

    /// Emitted when m_rxFrom mapping (active RX port) changes.
    void rxFromChanged();

    /// Emitted when m_txTo mapping (active TX port) changes.
    void txToChanged();

    // -----------------------
    // App-level signals
    // -----------------------

    /// Emitted when a full line of text has been received from the given port.
    void textReceivedFrom(int which, const QString &line);

    /// Emitted for user-visible error messages (shown in QML popup).
    void errorMessage(const QString &msg);

private:
    /// Helper bundle to access port-specific members (port, RX buffer, connections) by index.
    struct PortBundle {
        QSerialPort& port;
        QByteArray& rxBuf;
        QMetaObject::Connection& readyConnect;
        QMetaObject::Connection& errorConnect;
    };

    /// Non-const bundle selector for port 1 or 2.
    PortBundle bundle(int which);

    /// Const bundle selector for port 1 or 2 (wraps non-const version).
    const PortBundle bundle(int which) const {
        return const_cast<SerialBridge*>(this)->bundle(which);
    }

    /// Configure and open a QSerialPort with the given name/baud; returns true on success.
    bool openPort(QSerialPort& port, const QString& name, int baud);

    /// Convenience wrapper to emit an errorMessage().
    void emitError(const QString& msg) { emit errorMessage(msg); }

    /// Heuristic check whether a QSerialPortInfo looks like an RFD900x (VID/PID, etc.).
    static bool looksLikeRadio(const QSerialPortInfo &info);

    /// Active probe using AT command to verify attached device is a radio modem.
    static bool probeRadio_AT(QSerialPort &port);

    /// Connect readyRead/error handlers for the given port.
    void attachRx(int which);

    /// Disconnect readyRead/error handlers for the given port.
    void detachRx(int which);

    /// Slot-like handler for readyRead on a given port; buffers and parses lines.
    void handleReadyRead(int which);

    /// Slot-like handler for low-level serial errors on a given port.
    void handleError(int which, QSerialPort::SerialPortError e);

    /// Start a short RX pause window (used while transmitting on half-duplex links).
    void beginRxPause(int ms);

    /// Force end of RX pause and re-enable RX processing.
    void endRxPause();

    /// Return true if we are currently in an active RX pause window.
    bool isRxPause() const {
        if (!m_rxPaused) return false;
        return m_rxPauseTimer.isValid() && (m_rxPauseTimer.elapsed() < m_rxPauseMs);
    }

    /// Split accumulated RX buffer into complete lines and emit textReceivedFrom().
    void parseBufferedLines(int which);

    // -----------------------
    // Members
    // -----------------------

    QSerialPort m_p1, m_p2;          ///< Underlying serial ports for channel 1 and 2.
    QByteArray m_rx1_buffer, m_rx2_buffer;  ///< Line-assembly buffers for each port.

    int m_rxFrom = 1;                ///< Current port index used as RX source.
    int m_txTo   = 2;                ///< Current port index used as TX destination.

    bool m_rxPaused = false;         ///< Flag indicating RX is temporarily paused.
    QElapsedTimer m_rxPauseTimer;    ///< Timer used to measure RX pause duration.
    int m_rxPauseMs = 0;             ///< RX pause length in milliseconds.

    QMetaObject::Connection m_readyConnect1, m_error1; ///< Connections for port 1 signals.
    QMetaObject::Connection m_readyConnect2, m_error2; ///< Connections for port 2 signals.
    QMetaObject::Connection m_activeReadyConnect;      ///< Currently active RX connection in single-RX mode.

    QStringList m_ports;             ///< Cached list of discovered serial port names for UI.
};

#endif // SERIALBRIDGE_H
