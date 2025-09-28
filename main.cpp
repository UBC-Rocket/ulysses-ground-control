#include <QGuiApplication>
#include <QQmlApplicationEngine>

// #include <QQuickView>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
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


    return app.exec();
}
