#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QCommandLineParser>
#include <QTimer>
#include "SerialBridge.h"

// #include <QQuickView>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    SerialBridge bridge;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("bridge", &bridge);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("ulysses_ground_control", "Main");


    // QQuickView view;
    // view.setSource(QUrl(QStringLiteral("Source Files/Main.qml")));
    // view.showFullScreen();
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
