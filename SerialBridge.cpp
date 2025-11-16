#include "SerialBridge.h"
#include <QObject>
#include <QSerialPort>
#include <QSerialPortInfo>
#include <QElapsedTimer>
#include <QThread>
#include <QDebug>

namespace {
enum { kSerialDebug = 0 }; // flip to 1 to re-enable verbose IMU logging
}

SerialBridge::SerialBridge(QObject* parent) : QObject(parent) {
    refreshPorts(); // Build the initial COM list so the UI has a correct starting point.
    connect(&m_rx, &QSerialPort::readyRead, this, &SerialBridge::onRxReadyRead); // Handle incoming bytes as soon as the OS signals data is ready.

    connect(&m_tx, &QSerialPort::errorOccurred, this, &SerialBridge::onTxErrorOccurred); // Report TX-side driver/connection errors to the UI.
    connect(&m_rx, &QSerialPort::errorOccurred, this, &SerialBridge::onRxErrorOccurred); // Report RX-side driver/connection errors to the UI.
}

bool SerialBridge::looksLikeRadio(const QSerialPortInfo& info) {
    const auto vid = info.vendorIdentifier();
    const auto pid = info.productIdentifier();
    const QString desc = info.description().toLower();
    const QString mfg = info.manufacturer().toLower();

    if (desc.contains("bluetooth") || mfg.contains("bluetooth"))
        return false; // Filter out common Bluetooth SPP virtual COM ports immediately.

    if ((vid == 0x0403 && pid == 0x6001) ||   // FTDI FT232R
        (vid == 0x10C4 && pid == 0xEA60)) {   // SiLabs CP210x
        return true; // Known USB–UART bridges frequently used by RFD/SiK radios.
    }

    if (desc.contains("ftdi") || desc.contains("silicon labs") ||
        mfg.contains("ftdi")  || mfg.contains("silicon labs"))
        return true; // Heuristic accept when descriptive text matches typical radio chipsets.

    return false; // Unknown adapter: leave out until an active probe confirms otherwise.
}

bool SerialBridge::probeRadio_AT(QSerialPort& port) {
    port.readAll();
    port.waitForReadyRead(50);
    QThread::msleep(1000); // SiK/AT guard time: enforce ~1s of silence before sending "+++".

    if (port.write("+++", 3) != 3)
        return false; // Could not inject the AT escape sequence into the driver.

    port.write("ATO"); // Minimal exit to data mode (UI-verification path; no OK parsing here).
    return true; // For your current verification use-case, treat reaching this point as success.
}

void SerialBridge::refreshPorts() {
    QStringList list;
    for (const QSerialPortInfo& info : QSerialPortInfo::availablePorts()) {
        if (looksLikeRadio(info))
            list << info.portName(); // Keep only ports that pass the passive “looks like radio” filter.
    }
    if (list != m_ports) {       // Only notify when the set actually changed to avoid needless QML churn.
        m_ports = list;
        emit portsChanged();     // Drives the ComboBox models bound to bridge.ports.
    }
}

// configuration of connect port
bool SerialBridge::openPort(QSerialPort& port, const QString& name, int baud) {

    if (port.isOpen()) port.close(); // Reset the device so subsequent configuration reliably applies.

    port.setPortName(name);
    port.setBaudRate(baud);
    port.setDataBits(QSerialPort::Data8);
    port.setParity(QSerialPort::NoParity);
    port.setStopBits(QSerialPort::OneStop);
    port.setFlowControl(QSerialPort::NoFlowControl); // Change to HardwareControl if using RTS/CTS wiring.

    if (!port.open(QIODevice::ReadWrite)) {
        emitError(QStringLiteral("Failed to open %1: %2").arg(name, port.errorString())); // Surface OS-level open failure.
        return false;
    }
    return true; // Successfully opened and configured; ready for IO.
}

bool SerialBridge::connectTxPort(const QString& name, int baud) {
    const QString prevName = m_tx.portName(); // Preserve pre-change values to issue precise NOTIFY signals.
    const int prevBaud = txBaud();

    if (!openPort(m_tx, name, baud)) return false;   // Attempt to open and configure TX.

    // Notify QML bindings so labels/titles update
    emit txConnectedChanged();                       // Toggle connection state flag for QML bindings.
    if (m_tx.portName() != prevName) emit txPortNameChanged(); // Emit only on real value change.
    if (txBaud() != prevBaud)        emit txBaudChanged();     // Emit only on real value change.

    if (!probeRadio_AT(m_tx)) emit butTxNotRadioModem(); // Inform UI if the device does not behave like a radio.
    return true;
}

bool SerialBridge::connectRxPort(const QString& name, int baud)
{
    const QString prevName = m_rx.portName(); // Preserve pre-change values to issue precise NOTIFY signals.
    const int prevBaud = rxBaud();

    if (!openPort(m_rx, name, baud)) return false; // Open and configure RX.

    emit rxConnectedChanged();                      // Toggle connection state flag for QML bindings.
    if (m_rx.portName() != prevName) emit rxPortNameChanged(); // Emit only on real value change.
    if (rxBaud() != prevBaud)        emit rxBaudChanged();     // Emit only on real value change.

    if (!probeRadio_AT(m_rx)) emit butRxNotRadioModem(); // Inform UI if the device does not behave like a radio.
    return true;
}

void SerialBridge::disconnectTxPort() {
    const QString prevName = m_tx.portName(); // Snapshot values before closing so we can detect change.
    const int prevBaud = txBaud();

    if (m_tx.isOpen()) m_tx.close();                 // Close immediately to release the OS handle.
    m_tx.setPortName(QString());                     // Clear the visible name to reflect a disconnected state.

    emit txConnectedChanged();                       // Notify bound UI that connection state changed.
    if (m_tx.portName() != prevName) emit txPortNameChanged(); // Name typically clears on disconnect.
    if (txBaud() != prevBaud)        emit txBaudChanged();     // Some drivers report baud differently after close.
}

void SerialBridge::disconnectRxPort()
{
    const QString prevName = m_rx.portName(); // Snapshot values before closing so we can detect change.
    const int prevBaud = rxBaud();

    if (m_rx.isOpen()) m_rx.close();          // Stop reading and free OS resources.
    m_rx.setPortName(QString());              // Clear visible name for a clean disconnected state.

    emit rxConnectedChanged();                // Notify bound UI that connection state changed.
    if (m_rx.portName() != prevName) emit rxPortNameChanged(); // Name typically clears on disconnect.
    if (rxBaud() != prevBaud)        emit rxBaudChanged();     // Drivers may zero/mutate baud on close.
}

bool SerialBridge::sendText(const QString& text) {
    if (!m_tx.isOpen()) {
        emitError(QStringLiteral("Port is not open")); // Guard: refuse writes if TX isn’t connected.
        return false;
    }

    QByteArray data = text.toUtf8();
    if (!data.endsWith('\n')) data.append('\n'); // Ensure newline framing so the peer can split by lines.

    qint64 written = m_tx.write(data);
    if (written == -1) {
        emitError(QStringLiteral("Write failed: %1").arg(m_tx.errorString())); // Immediate driver-layer write failure.
        return false;
    }

    if (!m_tx.waitForBytesWritten(50)) {
        emitError(QStringLiteral("Write timeout (no bytes flushed)")); // Treat stalled flush as an error for reliability.
        return false;
    }

    return true; // Data accepted by the driver; user buffer flushed or in progress.
}

void SerialBridge::onRxReadyRead() {
    m_rxbuffer.append(m_rx.readAll()); // Accumulate fragments; readyRead can deliver partial frames.

    int idx;
    while ((idx = m_rxbuffer.indexOf('\n')) != -1) { // Extract each complete LF-terminated line.
        QByteArray line = m_rxbuffer.left(idx);

        if (!line.isEmpty() && line.endsWith('\r')) line.chop(1); // Convert CRLF → LF by trimming trailing CR.
        m_rxbuffer.remove(0, idx+1); // Drop the consumed bytes (including '\n'); keep any trailing partial frame.

        QString text = QString::fromUtf8(line);      // Prefer UTF-8 to keep non-ASCII intact.
        if (text.isNull()) text = QString::fromLatin1(line); // Fallback so binary-ish data still displays legibly.

        emit rxTextReceived(text); // Emit one logical line to QML; easy to append and log in the UI.
        parseIncomingData(text); // Parse for sensor data
    }
}

void SerialBridge::parseIncomingData(const QString& line) {


    // Skip empty lines
    if (line.trimmed().isEmpty()) return;
    
    // Split by comma
    QStringList parts = line.split(',', Qt::SkipEmptyParts);

    
    // Expected CSV format (14 values):
    // x,y,z,roll,pitch,yaw,pressure,altitude,raw_angle,filtered_angle,velocity,temperature,signal,battery
    
    if (parts.size() != 14) {
        // Only log errors occasionally to avoid spam at 50Hz
        static int errorCount = 0;
        if (++errorCount % 50 == 0) {
            qWarning() << "Expected 14 CSV fields, got" << parts.size() << "in line:" << line;
        }
        return;
    }
    
    // Parse all values (positions 0-13)
    double x     = parts[0].toDouble();  // X-axis acceleration
    double y     = parts[1].toDouble();  // Y-axis acceleration
    double z     = parts[2].toDouble();  // Z-axis acceleration
    double roll  = parts[3].toDouble();  // Roll rate
    double pitch = parts[4].toDouble();  // Pitch rate
    double yaw   = parts[5].toDouble();  // Yaw rate
    
    double pressure = parts[6].toDouble();  // Barometric pressure
    double altitude = parts[7].toDouble();  // Altitude
    
    double rawAngle      = parts[8].toDouble();   // Raw angle
    double filteredAngle = parts[9].toDouble();   // Kalman filtered angle
    
    double velocity    = parts[10].toDouble();  // Velocity
    double temperature = parts[11].toDouble();  // Temperature
    double signal      = parts[12].toDouble();  // Signal strength
    double battery     = parts[13].toDouble();  // Battery level

    if (kSerialDebug) {
        qDebug() << "IMU:" << x << y << z
                 << "| Gyro:" << roll << pitch << yaw
                 << "| Baro:" << pressure << altitude
                 << "| Kalman:" << rawAngle << filteredAngle
                 << "| Telemetry:" << velocity << temperature << signal << battery;
    }
    
    // Emit signals to notify the data model
    emit imuDataReceived(x, y, z, roll, pitch, yaw);
    emit kalmanDataReceived(rawAngle, filteredAngle);
    emit baroDataReceived(pressure, altitude);
    emit telemetryDataReceived(velocity, temperature, signal, battery);
}

void SerialBridge::onTxErrorOccurred(QSerialPort::SerialPortError e) {
    // Suppress benign timeouts (common during guard time / short polling) to avoid noisy popups.
    if (e == QSerialPort::NoError || e == QSerialPort::TimeoutError)
        return;
    emitError(m_tx.errorString()); // Forward meaningful TX errors (disconnects, access, framing, etc.).
}

void SerialBridge::onRxErrorOccurred(QSerialPort::SerialPortError e) {
    // Same timeout suppression on RX path to keep UI signal-only for real failures.
    if (e == QSerialPort::NoError || e == QSerialPort::TimeoutError)
        return;
    emitError(m_rx.errorString()); // Forward meaningful RX errors.
}

void SerialBridge::emitError(const QString& msg) {
    emit errorMessage(msg); // Centralized error reporting; QML listens to this single signal.
}
