#include "SerialBridge.h"
#include <QObject>
#include <QSerialPort>
#include <QSerialPortInfo>

SerialBridge::SerialBridge(QObject* parent) : QObject(parent) {
    refreshPorts();
    connect(&m_rx, &QSerialPort::readyRead, this, &SerialBridge::onRxReadyRead);

    connect(&m_tx, &QSerialPort::errorOccurred, this, &SerialBridge::onTxErrorOccurred);
    connect(&m_rx, &QSerialPort::errorOccurred, this, &SerialBridge::onRxErrorOccurred);
}

//插拔USB ports 信息会变
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

// configuration of connect port
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

void SerialBridge::disconnectTxPort() {
    const QString prevName = m_tx.portName();
    const int prevBaud = txBaud();

    if (m_tx.isOpen()) m_tx.close();                 // closing releases the COM port
    m_tx.setPortName(QString());                     // optional: clear for UI aesthetics

    emit txConnectedChanged();
    if (m_tx.portName() != prevName) emit txPortNameChanged();
    if (txBaud() != prevBaud)        emit txBaudChanged();
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

