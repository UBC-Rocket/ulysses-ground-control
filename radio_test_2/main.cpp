#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QCommandLineParser>
#include <QTimer>
#include "SerialBridge.h"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);

    SerialBridge bridge;
    // Defaults commonly used by RFD900x links; adjust in UI

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("bridge", &bridge);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [](QObject *obj, const QUrl &){ if (!obj) QCoreApplication::exit(-1); },
                     Qt::QueuedConnection);

    engine.loadFromModule("radio_test_2", "Main");
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
