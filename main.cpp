#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QCommandLineParser>
#include <QTimer>
#include "SerialBridge.h"
#include "SensorDataModel.h"
#include "CommandSender.h"
#include "AlarmReceiver.h"

int main(int argc, char *argv[])
{
    // Qt GUI application (event loop owner)
    QGuiApplication app(argc, argv);

    SerialBridge bridge;

    // QML engine + expose C++ backends to QML by name
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("bridge", &bridge);

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

