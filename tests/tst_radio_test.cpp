#include <QTest>
#include <QSignalSpy>
#include <QSerialPortInfo>
// #include "../SensorDataModel.h"
#include "../SerialBridge.h"
#include "../SensorDataModel.h"


class RadioTest: public QObject
{
    Q_OBJECT

private slots:
    void initTestCase()
    {
        qDebug("Called before everything else.");
    }


    void testAvailablePorts()
    {
        SerialBridge bridge;
        // QVERIFY(bridge.connectRxPort("COM7", 115200));

        SensorDataModel model;
        model.updateIMU(1,1,1,1,1,1);
        QCOMPARE(model.imuX(), 1);
    }


};

QTEST_MAIN(RadioTest)
#include "tst_radio_test.moc"

