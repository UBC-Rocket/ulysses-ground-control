#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QCommandLineParser>
#include <QTimer>
#include "SerialBridge.h"
<<<<<<< HEAD
#include "SensorDataModel.h"
=======
>>>>>>> 0fcf271 (Resolve stash conflicts: restore System Alarm/Control changes)
#include "CommandSender.h"
#include "AlarmReceiver.h"

int main(int argc, char *argv[])
{
    // Qt GUI application (event loop owner)
    QGuiApplication app(argc, argv);

<<<<<<< HEAD
    SerialBridge bridge;
    SensorDataModel sensorData;

    // Connect serial bridge to sensor data
    QObject::connect(&bridge, &SerialBridge::imuDataReceived,
                                &sensorData, &SensorDataModel::updateIMU);
    QObject::connect(&bridge, &SerialBridge::kalmanDataReceived,
                                &sensorData, &SensorDataModel::updateKalman);
    QObject::connect(&bridge, &SerialBridge::baroDataReceived,
                                &sensorData, &SensorDataModel::updateBaro);
    QObject::connect(&bridge, &SerialBridge::telemetryDataReceived,
                                &sensorData, &SensorDataModel::updateTelemetry);

    // QML engine + expose C++ backends to QML by name
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("bridge", &bridge);
    engine.rootContext()->setContextProperty("sensorData", &sensorData);
=======
    // Backend objects live for the duration of main()
    SerialBridge   bridge;                   // serial I/O backend
    CommandSender  commandsender(&bridge);   // sends commands via bridge
    AlarmReceiver  alarmreceiver(&bridge);   // receives/decodes alarms via bridge

    // QML engine + expose C++ backends to QML by name
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("bridge", &bridge);
    engine.rootContext()->setContextProperty("commandsender", &commandsender);
    engine.rootContext()->setContextProperty("alarmreceiver", &alarmreceiver);
>>>>>>> 0fcf271 (Resolve stash conflicts: restore System Alarm/Control changes)

    // If QML fails to load, quit with error code
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    // Load the QML entry point from the compiled QML module
    engine.loadFromModule("ulysses_ground_control", "Main");

    // Safety check: no root objects means load failed
    if (engine.rootObjects().isEmpty())
        return -1;

    // Start the event loop
    return app.exec();
}

