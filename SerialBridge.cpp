#include "SerialBridge.h"
#include <QObject>
#include <QSerialPort>
#include <QSerialPortInfo>
#include <QElapsedTimer>
#include <QThread>

SerialBridge::SerialBridge(QObject* parent) : QObject(parent) {
    refreshPorts(); // Build the initial COM list so the UI has something to show.
}

bool SerialBridge::looksLikeRadio(const QSerialPortInfo& info) {
    const auto vid = info.vendorIdentifier();
    const auto pid = info.productIdentifier();
    const QString desc = info.description().toLower();
    const QString mfg = info.manufacturer().toLower();

    // Quickly reject typical Bluetooth virtual COM ports.
    if (desc.contains("bluetooth") || mfg.contains("bluetooth"))
        return false;

    // Known USB–UART bridge IDs commonly used for RFD/SiK radios.
    if ((vid == 0x0403 && pid == 0x6001) ||   // FTDI FT232R
        (vid == 0x10C4 && pid == 0xEA60)) {   // SiLabs CP210x
        return true;
    }

    // Fuzzy match against common USB–UART manufacturer strings.
    if (desc.contains("ftdi") || desc.contains("silicon labs") ||
        mfg.contains("ftdi")  || mfg.contains("silicon labs"))
        return true;

    // Anything else is ignored until an explicit probe says otherwise.
    return false;
}

bool SerialBridge::probeRadio_AT(QSerialPort& port) {
    port.readAll();                 // Drop any stale bytes.
    port.waitForReadyRead(50);
    QThread::msleep(1000);          // Enforce SiK guard time (~1s silence) before "+++".

    if (port.write("+++", 3) != 3)
        return false;               // Can't even send the escape sequence.

    port.write("ATO");              // Minimal data-mode exit; we don't parse the reply here.
    return true;                    // For now, reaching this point is treated as “probe OK”.
}

void SerialBridge::refreshPorts() {
    QStringList list;
    for (const QSerialPortInfo& info : QSerialPortInfo::availablePorts()) {
        if (looksLikeRadio(info))
            list << info.portName(); // Only keep ports that pass the heuristic filter.
    }

    // Only notify QML if the list actually changed (prevents unnecessary UI churn).
    if (list != m_ports) {
        m_ports = list;
        emit portsChanged();
    }
}

SerialBridge::PortBundle SerialBridge::bundle(int which) {
    if (which == 1) {
        return PortBundle{ m_p1, m_rx1_buffer, m_readyConnect1, m_error1 };
    } else {
        return PortBundle{ m_p2, m_rx2_buffer, m_readyConnect2, m_error2 };
    }
}

bool SerialBridge::openPort(QSerialPort& port, const QString& name, int baud) {
    if (port.isOpen())
        port.close(); // Ensure we start from a clean state.

    port.setPortName(name);
    port.setBaudRate(baud);
    port.setDataBits(QSerialPort::Data8);
    port.setParity(QSerialPort::NoParity);
    port.setStopBits(QSerialPort::OneStop);
    port.setFlowControl(QSerialPort::NoFlowControl); // Change if using hardware flow control.

    if (!port.open(QIODevice::ReadWrite)) {
        emitError(QStringLiteral("Failed to open %1: %2").arg(name, port.errorString()));
        return false;
    }
    return true;
}

bool SerialBridge::connectPort(int which, const QString& name, int baud) {
    // Prevent assigning the same OS port to both “P1” and “P2”.
    if (which == 1 && m_p2.isOpen() && m_p2.portName() == name) {
        emitError(QStringLiteral("Port %1 is already assigned to P2. Disconnect P2 first.").arg(name));
        return false;
    }
    if (which == 2 && m_p1.isOpen() && m_p1.portName() == name) {
        emitError(QStringLiteral("Port %1 is already assigned to P1. Disconnect P1 first.").arg(name));
        return false;
    }

    auto b = bundle(which);
    if (!openPort(b.port, name, baud))
        return false;

    emit connectedChanged(which, true);
    emit portNameChanged(which);
    emit baudChanged(which);

    // Attach RX handlers for this port (can listen on both ports).
    attachRx(which);

    // Light sanity check that this behaves like a radio modem.
    if (!probeRadio_AT(b.port))
        emit butNotRadioModem(which);

    return true;
}

void SerialBridge::disconnectPort(int which) {
    auto b = bundle(which);
    if (b.port.isOpen()) {
        b.port.close();
    }

    // Remove signal connections so we don’t read from a closed port.
    detachRx(which);
    emit connectedChanged(which, false);
}

bool SerialBridge::setTxTo(int which) {
    if (which != 1 && which != 2) {
        emitError("setTxTo: which must be 1 or 2");
        return false;
    }

    if (!bundle(which).port.isOpen()) {
        emitError("setTxTo: selected port is not open");
        return false;
    }

    // No change → nothing to do.
    if (m_txTo == which)
        return true;

    m_txTo = which;
    emit txToChanged();
    return true;
}

bool SerialBridge::setRxFrom(int which) {
    if (which != 1 && which != 2) {
        emitError("setTxTo: which must be 1 or 2");
        return false;
    }

    if (!isConnected(which)) {
        emitError("setRxFrom: selected port is not open");
        return false;
    }

    if (m_rxFrom == which)
        return true;

    // Switch RX source and move handlers over to the new port.
    detachRx(which);
    m_rxFrom = which;
    attachRx(which);
    emit rxFromChanged();
    return true;
}

void SerialBridge::attachRx(int which) {
    auto b = bundle(which);

    // Reconnect error handler for this port.
    QObject::disconnect(b.errorConnect);
    b.errorConnect = connect(
        &b.port, &QSerialPort::errorOccurred, this,
        [this, which](QSerialPort::SerialPortError e) { handleError(which, e); }
        );

    // Reconnect readyRead handler for this port.
    QObject::disconnect(b.readyConnect);
    b.readyConnect = connect(
        &b.port, &QIODevice::readyRead, this,
        [this, which] { handleReadyRead(which); }
        );
}

void SerialBridge::detachRx(int which) {
    auto b = bundle(which);
    QObject::disconnect(b.readyConnect);
    QObject::disconnect(b.errorConnect);
}

void SerialBridge::beginRxPause(int ms) {
    m_rxPaused = true;
    m_rxPauseMs = ms;
    m_rxPauseTimer.restart(); // Start timing the pause window.
}

void SerialBridge::endRxPause() {
    m_rxPaused = false;
    m_rxPauseMs = 0;
}

bool SerialBridge::sendText(int which, const QString& text) {
    auto b = bundle(which);
    if (!b.port.isOpen()) {
        emitError(QString("sendTextOn: P%1 not open").arg(which));
        return false;
    }

    // If TX and RX share the same physical port, we temporarily pause RX while we TX.
    const bool shared = (which == m_rxFrom);

    QString line = text;
    if (!line.endsWith('\n'))
        line.append('\n'); // Normalize to LF-terminated lines for the receiver/parser.

    const QByteArray bytes = line.toUtf8();

    int estMs = 0;
    if (shared) {
        // Rough TX-time estimate: bytes * 10 bits / baud → ms, clamped to a small range.
        const int baud = b.port.baudRate();
        const int nbytes = bytes.size();
        double t_ms = (baud > 0)
                          ? (double(nbytes) * 10.0 * 1000.0 / double(baud))
                          : 2.0;
        estMs = qBound(1, int(qCeil(t_ms)) + 1, 10);
        beginRxPause(estMs);
    }

    const qint64 n = b.port.write(bytes);
    if (n < 0) {
        emitError(QStringLiteral("Write failed on P%1: %2").arg(which).arg(b.port.errorString()));
        if (shared)
            endRxPause();
        return false;
    }

    b.port.flush();
    b.port.waitForBytesWritten(10); // Short blocking wait to push bytes out.

    if (shared) {
        endRxPause();
        parseBufferedLines(which);  // Process anything that arrived during the pause.
    }
    return true;
}

void SerialBridge::handleReadyRead(int which) {
    auto b = bundle(which);
    b.rxBuf.append(b.port.readAll()); // Append any newly arrived data into the buffer.

    // While TX pause is active we only accumulate data, we don't parse lines yet.
    if (isRxPause())
        return;

    parseBufferedLines(which);
}

void SerialBridge::parseBufferedLines(int which) {
    auto b = bundle(which);

    // Grab any remaining bytes in case readyRead fired again between calls.
    b.rxBuf.append(b.port.readAll());

    int idx;
    // Consume full lines terminated by '\n'; keep partial line in buffer.
    while ((idx = b.rxBuf.indexOf('\n')) != -1) {
        QByteArray line = b.rxBuf.left(idx);

        // Convert CRLF → LF by dropping trailing '\r'.
        if (!line.isEmpty() && line.endsWith('\r')) {
            line.chop(1);
        }

        // Remove this line (and its '\n') from the buffer.
        b.rxBuf.remove(0, idx + 1);

        // Prefer UTF-8; fall back to Latin-1 if decoding fails.
        QString text = QString::fromUtf8(line);
        if (text.isNull()) {
            text = QString::fromLatin1(line);
        }

        // Emit a clean logical line to whoever is listening (QML, alarm system, etc.).
        emit textReceivedFrom(which, text);
    }
}

void SerialBridge::handleError(int which, QSerialPort::SerialPortError e) {
    // Ignore benign notifications.
    if (e == QSerialPort::NoError || e == QSerialPort::TimeoutError)
        return;

    auto& p = (which == 1) ? m_p1 : m_p2;
    emitError(QStringLiteral("Serial error on P%1: %2").arg(which).arg(p.errorString()));
}
