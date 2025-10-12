#ifndef SERIALBRIDGE_H
#define SERIALBRIDGE_H

#pragma once
#include <QObject>
#include <QSerialPort>
#include <QSerialPortInfo>

class SerialBridge : public QObject {
    Q_OBJECT
    Q_PROPERTY(QStringList ports READ ports NOTIFY portsChanged)

    Q_PROPERTY(bool txConnected READ txConnected NOTIFY txConnectedChanged)
    Q_PROPERTY(bool rxConnected READ rxConnected NOTIFY rxConnectedChanged)
    Q_PROPERTY(QString txPortName READ txPortName NOTIFY txPortNameChanged)
    Q_PROPERTY(QString rxPortName READ rxPortName NOTIFY rxPortNameChanged)
    Q_PROPERTY(int txBaud READ txBaud NOTIFY txBaudChanged)
    Q_PROPERTY(int rxBaud READ rxBaud NOTIFY rxBaudChanged)


public:
    explicit SerialBridge(QObject* parent = nullptr);

    // qml callable API
    Q_INVOKABLE void refreshPorts();
    Q_INVOKABLE bool connectTxPort(const QString& name, int baudRate);
    Q_INVOKABLE bool connectRxPort(const QString& name, int baudRate);
    Q_INVOKABLE void disconnectTxPort();
    Q_INVOKABLE void disconnectRxPort();
    Q_INVOKABLE bool sendText(const QString& text);

    // getters
    QStringList ports() const {return m_ports; }

    bool txConnected() const {return m_tx.isOpen(); }
    bool rxConnected() const {return m_rx.isOpen(); }
    QString txPortName() const {return m_tx.portName(); }
    QString rxPortName() const {return m_rx.portName(); }
    int txBaud() const {return m_tx.baudRate(); }
    int rxBaud() const {return m_rx.baudRate(); }

signals:
    // model ui change notify
    void portsChanged();

    void txBaudChanged();
    void rxBaudChanged();
    void txConnectedChanged();
    void rxConnectedChanged();
    void txPortNameChanged();
    void rxPortNameChanged();

    // app level signals
    void errorMessage(const QString &msg);
    void rxTextRecieved(const QString &line);

private slots:
    // handlers for QSerialPort events
    void onRxReadyRead();
    void onTxErrorOccurred(QSerialPort::SerialPortError error);
    void onRxErrorOccurred(QSerialPort::SerialPortError error);


private:
    // push error to qml
    void emitError(const QString &msg);

    bool openPort(QSerialPort& port, const QString& name, int baud);

    QSerialPort m_tx;
    QSerialPort m_rx;
    QByteArray m_rxbuffer;
    QStringList m_ports;
};

#endif // SERIALBRIDGE_H
