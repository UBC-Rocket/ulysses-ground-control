#ifndef SERIALBRIDGE_H
#define SERIALBRIDGE_H

#pragma once
#include <QObject>
#include <QSerialPort>
#include <QSerialPortInfo>

/**
 * @brief SerialBridge
 * QML-friendly wrapper that manages TWO serial ports at once:
 *  - m_tx : port used for transmitting (we write to it)
 *  - m_rx : port used for receiving (we read from it)
 * It also exposes properties/signals so a Qt Quick UI can bind to connection
 * state, port names, baud rates, and incoming text lines.
 */
class SerialBridge : public QObject {
    Q_OBJECT

    // Exposes the current list of available serial port names (e.g., "COM7", "COM8").
    // Call refreshPorts() to rescan; emits portsChanged when the list changes.
    Q_PROPERTY(QStringList ports READ ports NOTIFY portsChanged)

    // Connection state of each side; true when that port is open.
    Q_PROPERTY(bool txConnected READ txConnected NOTIFY txConnectedChanged)
    Q_PROPERTY(bool rxConnected READ rxConnected NOTIFY rxConnectedChanged)

    // The current OS port names bound to each side (empty if not connected).
    Q_PROPERTY(QString txPortName READ txPortName NOTIFY txPortNameChanged)
    Q_PROPERTY(QString rxPortName READ rxPortName NOTIFY rxPortNameChanged)

    // The current UART baud rates applied to each side (valid when connected).
    Q_PROPERTY(int txBaud READ txBaud NOTIFY txBaudChanged)
    Q_PROPERTY(int rxBaud READ rxBaud NOTIFY rxBaudChanged)

public:
    /**
     * @brief SerialBridge constructor
     * Initializes the object and typically wires up signals/slots in the .cpp.
     * The implementation also calls refreshPorts() to populate the initial port list.
     */
    explicit SerialBridge(QObject* parent = nullptr);

    // -----------------------
    // QML-callable API
    // -----------------------

    /**
     * @brief refreshPorts
     * Rescans the system for available serial ports using QSerialPortInfo::availablePorts().
     * If the list differs from the cached list, updates it and emits portsChanged().
     */
    Q_INVOKABLE void refreshPorts();

    /**
     * @brief connectTxPort
     * Opens and configures the TX (transmit) serial port with the given name and baud.
     * On success, emits txConnectedChanged(), and if applicable txPortNameChanged()/txBaudChanged().
     * @param name     OS port name (e.g., "COM7" or "/dev/ttyUSB0")
     * @param baudRate UART baud rate (e.g., 57600, 115200)
     * @return true if opened successfully; false on error (error surfaced via errorMessage()).
     */
    Q_INVOKABLE bool connectTxPort(const QString& name, int baudRate);

    /**
     * @brief connectRxPort
     * Opens and configures the RX (receive) serial port with the given name and baud.
     * On success, emits rxConnectedChanged(), and if applicable rxPortNameChanged()/rxBaudChanged().
     * @param name     OS port name (e.g., "COM8" or "/dev/ttyUSB1")
     * @param baudRate UART baud rate (e.g., 57600, 115200)
     * @return true if opened successfully; false on error (error surfaced via errorMessage()).
     */
    Q_INVOKABLE bool connectRxPort(const QString& name, int baudRate);

    /**
     * @brief disconnectTxPort
     * Closes the TX serial port if open, clears its stored name for UI aesthetics,
     * and emits txConnectedChanged(); also emits txPortNameChanged()/txBaudChanged() if values changed.
     */
    Q_INVOKABLE void disconnectTxPort();

    /**
     * @brief disconnectRxPort
     * Closes the RX serial port if open, clears its stored name for UI aesthetics,
     * and emits rxConnectedChanged(); also emits rxPortNameChanged()/rxBaudChanged() if values changed.
     */
    Q_INVOKABLE void disconnectRxPort();

    /**
     * @brief sendText
     * Sends a UTF-8 encoded line out of the TX port. Appends '\n' if missing so the receiver
     * can parse line-by-line. Waits briefly for bytesWritten for better UX.
     * @param text The text payload to send.
     * @return true on success; false if TX is not open or write/flush fails (errorMessage() emitted).
     */
    Q_INVOKABLE bool sendText(const QString& text);

    // -----------------------
    // Property getters
    // -----------------------

    /// Returns the current cached list of available serial port names.
    Q_INVOKABLE QStringList ports() const { return m_ports; }

    /// True if the TX serial port (m_tx) is open.
    bool txConnected() const { return m_tx.isOpen(); }

    /// True if the RX serial port (m_rx) is open.
    bool rxConnected() const { return m_rx.isOpen(); }

    /// The OS port name bound to the TX side (empty if not connected).
    Q_INVOKABLE QString txPortName() const { return m_tx.portName(); }

    /// The OS port name bound to the RX side (empty if not connected).
    QString rxPortName() const { return m_rx.portName(); }

    /// The current UART baud of the TX side (valid when connected).
    int txBaud() const { return m_tx.baudRate(); }

    /// The current UART baud of the RX side (valid when connected).
    int rxBaud() const { return m_rx.baudRate(); }

signals:
    // -----------------------
    // Property/Model change notifications (for QML bindings)
    // -----------------------

    /// Emitted when the available port list changes after a refresh.
    void portsChanged();

    /// Emitted when the TX or RX baud value changes (typically after (dis)connect).
    void txBaudChanged();
    void rxBaudChanged();

    /// Emitted when the TX or RX connection open/closed state changes.
    void txConnectedChanged();
    void rxConnectedChanged();

    /// Emitted when the TX or RX port name changes.
    void txPortNameChanged();
    void rxPortNameChanged();

    /// Emitted when the TX ot RX port does not connected to a radio modem
    void butTxNotRadioModem();
    void butRxNotRadioModem();

    // -----------------------
    // App-level signals
    // -----------------------

    /**
     * @brief errorMessage
     * Human-readable error detail suitable for showing in the UI (e.g., toast/status bar).
     */
    void errorMessage(const QString &msg);

    /**
     * @brief rxTextRecieved
     * Emitted whenever a complete line has been parsed from the RX port.
     * NOTE: Spelling is kept as in your current code ("Recieved"). If you later rename
     * to rxTextReceived, remember to also update QML handlers and moc-generated code.
     */
    void rxTextReceived(const QString &line);

    /**
     * Reading raw String into correspoding sensor data
     */
    void imuDataReceived(double x, double y, double z, double roll, double pitch, double yaw);
    void kalmanDataReceived(double rawAngle, double filteredAngle);
    void baroDataReceived(double pressure, double altitude);
    void telemetryDataReceived(double velocity, double temperature, double signal, double battery);

private slots:
    /**
     * @brief onRxReadyRead
     * Slot connected to m_rx.readyRead(). Accumulates incoming bytes into m_rxbuffer,
     * splits by '\n' boundaries, trims optional '\r', decodes as UTF-8 (fallback Latin1),
     * and emits rxTextRecieved(line) for each complete line.
     */
    void onRxReadyRead();

    /**
     * @brief onTxErrorOccurred
     * Slot connected to m_tx.errorOccurred(). Ignores NoError; otherwise emits errorMessage()
     * with the driver’s error string to surface issues in the UI.
     */
    void onTxErrorOccurred(QSerialPort::SerialPortError error);

    /**
     * @brief onRxErrorOccurred
     * Slot connected to m_rx.errorOccurred(). Ignores NoError; otherwise emits errorMessage()
     * with the driver’s error string to surface issues in the UI.
     */
    void onRxErrorOccurred(QSerialPort::SerialPortError error);

private:
    /**
     * @brief emitError
     * Convenience helper to emit errorMessage(msg). Centralizes error surfacing so callers
     * do not duplicate UI plumbing.
     */
    void emitError(const QString &msg);
    static bool looksLikeRadio(const QSerialPortInfo &info);
    static bool probeRadio_AT(QSerialPort &port);

    /**
     * @brief openPort
     * Internal helper to configure a QSerialPort with 8N1 / no flow control and open it
     * for ReadWrite. If already open, closes first to reconfigure safely.
     * @param port The QSerialPort instance to open (TX or RX).
     * @param name OS port name.
     * @param baud UART baud rate.
     * @return true if open succeeded; false otherwise (also emits errorMessage()).
     */
    bool openPort(QSerialPort& port, const QString& name, int baud);

    void parseIncomingData(const QString& line);

    // -----------------------
    // Members
    // -----------------------

    QSerialPort m_tx;       ///< The transmitter port (bytes are written here).
    QSerialPort m_rx;       ///< The receiver port (bytes are read/parsed here).

    QByteArray  m_rxbuffer; ///< Accumulates incoming bytes until newline(s) are found.
    QStringList m_ports;    ///< Cached list of available ports for the UI.
};

#endif // SERIALBRIDGE_H

