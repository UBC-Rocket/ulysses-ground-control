#include "SerialBridge.h"
#include <QObject>
#include <QSerialPort>
#include <QSerialPortInfo>

SerialBridge::SerialBridge(QObject* parent) : QObject(parent) {
    refreshPorts(); // populate initial COM list so UI starts accurate
    connect(&m_rx, &QSerialPort::readyRead, this, &SerialBridge::onRxReadyRead); // event-driven RX: parse as bytes arrive

    connect(&m_tx, &QSerialPort::errorOccurred, this, &SerialBridge::onTxErrorOccurred); // surface TX-side driver/USB errors
    connect(&m_rx, &QSerialPort::errorOccurred, this, &SerialBridge::onRxErrorOccurred); // surface RX-side driver/USB errors
}

void SerialBridge::refreshPorts() {
    QStringList list;
    for (const QSerialPortInfo& info : QSerialPortInfo::availablePorts()) {
        list << info.portName(); // collect displayable names (e.g., COM7, /dev/ttyUSB0)
    }
    if (list != m_ports) {       // notify only if list changed to avoid redundant QML updates
        m_ports = list;
        emit portsChanged();
    }
}

// configuration of connect port
bool SerialBridge::openPort(QSerialPort& port, const QString& name, int baud) {

    if (port.isOpen()) port.close(); // close first to ensure reconfig applies on all drivers

    port.setPortName(name);
    port.setBaudRate(baud);
    port.setDataBits(QSerialPort::Data8);
    port.setParity(QSerialPort::NoParity);
    port.setStopBits(QSerialPort::OneStop);
    port.setFlowControl(QSerialPort::NoFlowControl); // switch to HardwareControl if RTS/CTS enabled on radios

    if (!port.open(QIODevice::ReadWrite)) {
        emitError(QStringLiteral("Failed to open %1: %2").arg(name, port.errorString())); // show OS-specific reason
        return false;
    }
    return true; // success: port is ready for immediate I/O
}

bool SerialBridge::connectTxPort(const QString& name, int baud) {
    const QString prevName = m_tx.portName(); // snapshot for precise NOTIFY deltas
    const int prevBaud = txBaud();

    if (!openPort(m_tx, name, baud)) return false;   // configure and open

    // Notify QML bindings so labels/titles update
    emit txConnectedChanged();                       // connection state toggled
    if (m_tx.portName() != prevName) emit txPortNameChanged(); // emit only if value changed
    if (txBaud() != prevBaud)        emit txBaudChanged();     // emit only if value changed
    return true;
}

bool SerialBridge::connectRxPort(const QString& name, int baud)
{
    const QString prevName = m_rx.portName(); // snapshot for precise NOTIFY deltas
    const int prevBaud = rxBaud();

    if (!openPort(m_rx, name, baud)) return false; // open RX side

    emit rxConnectedChanged();                      // connection state toggled
    if (m_rx.portName() != prevName) emit rxPortNameChanged(); // emit only if value changed
    if (rxBaud() != prevBaud)        emit rxBaudChanged();     // emit only if value changed
    return true;
}

void SerialBridge::disconnectTxPort() {
    const QString prevName = m_tx.portName(); // cache pre-close values to compare after
    const int prevBaud = txBaud();

    if (m_tx.isOpen()) m_tx.close();                 // closing releases OS handle immediately
    m_tx.setPortName(QString());                     // optional: clear for UI aesthetics

    emit txConnectedChanged();                       // connection state toggled
    if (m_tx.portName() != prevName) emit txPortNameChanged(); // name usually changes (cleared)
    if (txBaud() != prevBaud)        emit txBaudChanged();     // some drivers reset reported baud on close
}

void SerialBridge::disconnectRxPort()
{
    const QString prevName = m_rx.portName(); // cache pre-close values to compare after
    const int prevBaud = rxBaud();

    if (m_rx.isOpen()) m_rx.close();          // stop receiving and free OS resources
    m_rx.setPortName(QString());              // clear for a clean disconnected state

    emit rxConnectedChanged();                // connection state toggled
    if (m_rx.portName() != prevName) emit rxPortNameChanged(); // name usually changes (cleared)
    if (rxBaud() != prevBaud)        emit rxBaudChanged();     // drivers may zero/alter baud on close
}

bool SerialBridge::sendText(const QString& text) {
    if (!m_tx.isOpen()) {
        emitError(QStringLiteral("Port is not open")); // guard: avoid writing to invalid handle
        return false;
    }

    QByteArray data = text.toUtf8();
    if (!data.endsWith('\n')) data.append('\n'); // enforce line-framing so peer splits on '\n'

    qint64 written = m_tx.write(data);
    if (written == -1) {
        emitError(QStringLiteral("Write failed: %1").arg(m_tx.errorString())); // immediate driver error
        return false;
    }

    if (!m_tx.waitForBytesWritten(50)) {
        emitError(QStringLiteral("Write timeout (no bytes flushed)")); // conservative: treat rare stalls as error
        return false;
    }

    return true; // bytes accepted and likely flushed from user buffer into driver
}

void SerialBridge::onRxReadyRead() {
    m_rxbuffer.append(m_rx.readAll()); // accumulate partial chunks; readyRead may deliver fragments

    int idx;
    while ((idx = m_rxbuffer.indexOf('\n')) != -1) { // extract every complete line currently available
        QByteArray line = m_rxbuffer.left(idx);

        if (!line.isEmpty() && line.endsWith('\r')) line.chop(1); // normalize CRLF→LF by trimming trailing '\r'
        m_rxbuffer.remove(0, idx+1); // drop consumed bytes including delimiter; keep any partial remainder

        QString text = QString::fromUtf8(line);      // prefer UTF-8 for wide characters
        if (text.isNull()) text = QString::fromLatin1(line); // fallback preserves visibility for non-UTF8 bytes

        emit rxTextRecieved(text); // one signal per line keeps QML appending logic simple/predictable
    }
}

void SerialBridge::onTxErrorOccurred(QSerialPort::SerialPortError error) {
    if (error == QSerialPort::NoError) {
        return; // ignore benign transitions where stack clears error state
    }
    emitError(m_tx.errorString()); // forward driver/OS detail (e.g., unplug, access denied, framing)
}

void SerialBridge::onRxErrorOccurred(QSerialPort::SerialPortError error) {
    if (error == QSerialPort::NoError) {
        return; // ignore benign transitions where stack clears error state
    }
    emitError(m_rx.errorString()); // forward driver/OS detail for display/logging
}

void SerialBridge::emitError(const QString& msg) {
    emit errorMessage(msg); // single funnel: UI listens to one signal for all backend errors
}
