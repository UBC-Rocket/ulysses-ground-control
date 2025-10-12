#include "SerialBridge.h"
#include <QObject>
#include <QSerialPort>
#include <QSerialPortInfo>


/*
 * Tx: Transmit(sender) radio modom
 * Rx: Receiver radio modem
 */

/*
 * introduce SerialBridge with dual-port (tx/rx) setup and signal wiring

- Construct QObject-based SerialBridge
- Hook readyRead() on RX and errorOccurred() on both TX/RX
- Provide central emitError() helper and errorMessage signal

 */
SerialBridge::SerialBridge(QObject* parent) : QObject(parent) {
    refreshPorts();
    connect(&m_rx, &QSerialPort::readyRead, this, &SerialBridge::onRxReadyRead);

    connect(&m_tx, &QSerialPort::errorOccurred, this, &SerialBridge::onTxErrorOccurred);
    connect(&m_rx, &QSerialPort::errorOccurred, this, &SerialBridge::onRxErrorOccurred);
}



/*
 * add refreshPorts() with QSerialPortInfo listing and NOTIFY

- Scan available ports and expose as QStringList
- Emit portsChanged only on actual delta to avoid UI churn

 */
void SerialBridge::refreshPorts() {
    QStringList list;
    for (const QSerialPortInfo& info : QSerialPortInfo::availablePorts()) {
        list << info.portName();
    }
    if (list != m_ports) {
        m_ports = list;
        emit portsChanged();
    }
}

/*
 * add openPort() utility to configure and open a QSerialPort

- Configure 8N1, no parity, no flow control (RFD900x defaults)
- Open ReadWrite; surface human-readable errors

 */
bool SerialBridge::openPort(QSerialPort& port, const QString& name, int baud) {

    if (port.isOpen()) port.close();

    port.setPortName(name);
    port.setBaudRate(baud);
    port.setDataBits(QSerialPort::Data8);
    port.setParity(QSerialPort::NoParity);
    port.setStopBits(QSerialPort::OneStop);
    port.setFlowControl(QSerialPort::NoFlowControl);

    if (!port.open(QIODevice::ReadWrite)) {
        emitError(QStringLiteral("Failed to open %1: %2").arg(name, port.errorString()));
        return false;
    }
    return true;
}

/*
 * implement connectTxPort()/disconnectRxPort() with property change signals

- Open/close TX side; update port name + baud bindings
- Emit txConnectedChanged, txPortNameChanged, txBaudChanged as needed

 */
bool SerialBridge::connectTxPort(const QString& name, int baud) {
    const QString prevName = m_tx.portName();
    const int prevBaud = txBaud();

    if (!openPort(m_tx, name, baud)) return false;   // configure and open

    // Notify QML bindings so labels/titles update
    emit txConnectedChanged();
    if (m_tx.portName() != prevName) emit txPortNameChanged();
    if (txBaud() != prevBaud)        emit txBaudChanged();
    return true;
}

void SerialBridge::disconnectTxPort() {
    const QString prevName = m_tx.portName();
    const int prevBaud = txBaud();

    if (m_tx.isOpen()) m_tx.close();                 // closing releases the COM port
    m_tx.setPortName(QString());                     // clear for UI aesthetics

    emit txConnectedChanged();
    if (m_tx.portName() != prevName) emit txPortNameChanged();
    if (txBaud() != prevBaud)        emit txBaudChanged();
}

/*
 * implement connectRxPort()/disconnectRxPort() with property change signals

- Open/close RX side; update port name + baud bindings
- Emit rxConnectedChanged, rxPortNameChanged, rxBaudChanged as needed

 */
bool SerialBridge::connectRxPort(const QString& name, int baud)
{
    const QString prevName = m_rx.portName();
    const int prevBaud = rxBaud();

    if (!openPort(m_rx, name, baud)) return false;

    emit rxConnectedChanged();
    if (m_rx.portName() != prevName) emit rxPortNameChanged();
    if (rxBaud() != prevBaud)        emit rxBaudChanged();
    return true;
}

void SerialBridge::disconnectRxPort()
{
    const QString prevName = m_rx.portName();
    const int prevBaud = rxBaud();

    if (m_rx.isOpen()) m_rx.close();
    m_rx.setPortName(QString());

    emit rxConnectedChanged();
    if (m_rx.portName() != prevName) emit rxPortNameChanged();
    if (rxBaud() != prevBaud)        emit rxBaudChanged();
}

/*
 * implement sendText() with UTF-8 + newline framing and flush

- Encode to UTF-8; ensure trailing '\n' for line-based protocol
- Write asynchronously; wait briefly for bytesWritten with timeout
- Emit descriptive errors on failure

 */
bool SerialBridge::sendText(const QString& text) {
    if (!m_tx.isOpen()) {
        emitError(QStringLiteral("Port is not open"));
        return false;
    }

    QByteArray data = text.toUtf8();
    if (!data.endsWith('\n')) data.append('\n');

    qint64 written = m_tx.write(data);
    if (written == -1) {
        emitError(QStringLiteral("Write failed: %1").arg(m_tx.errorString()));
        return false;
    }

    if (!m_tx.waitForBytesWritten(50)) {
        emitError(QStringLiteral("Write timeout (no bytes flushed)"));
        return false;
    }

    return true;
}

/*
 * implement onRxReadyRead() line buffer with CRLF handling

- Append incoming bytes to RX buffer
- Split on '\n'; trim optional '\r'
- Decode UTF-8 (fallback Latin1) and emit rxTextRecieved(text)

 */
void SerialBridge::onRxReadyRead() {
    m_rxbuffer.append(m_rx.readAll());

    int idx;
    while ((idx = m_rxbuffer.indexOf('\n')) != -1) {
        QByteArray line = m_rxbuffer.left(idx);

        if (!line.isEmpty() && line.endsWith('\r')) line.chop(1);
        m_rxbuffer.remove(0, idx+1);

        QString text = QString::fromUtf8(line);
        if (text.isNull()) text = QString::fromLatin1(line);

        emit rxTextRecieved(text);
    }
}

/*
 * wire onTxErrorOccurred/onRxErrorOccurred to emit UI-friendly errors

- Ignore NoError
- Forward driver error strings via errorMessage

 */
void SerialBridge::onTxErrorOccurred(QSerialPort::SerialPortError error) {
    if (error == QSerialPort::NoError) {
        return;
    }
    emitError(m_tx.errorString());
}

void SerialBridge::onRxErrorOccurred(QSerialPort::SerialPortError error) {
    if (error == QSerialPort::NoError) {
        return;
    }
    emitError(m_rx.errorString());
}

void SerialBridge::emitError(const QString& msg) {
    emit errorMessage(msg);
}

