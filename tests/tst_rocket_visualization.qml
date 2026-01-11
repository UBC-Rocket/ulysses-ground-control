import QtQuick 2.15
import QtTest 1.0
import "../"


TestCase {
    name: "test_rocket_visualization"
    height: 800
    width: 800
    visible: true
    when: windowShown

    QtObject {
        id: sensorData

        property real imuX: 0
        property real imuY: 0
        property real imuZ: 0
        property real roll: 0
        property real pitch: 0
        property real yaw: 0

        property real pressure: 0
        property real altitude: 0

        property real velocity: 0
        property real temperature: 0
        property real signal: 0
        property real battery: 0

        function emitFakeIMUData(x, y, z, r, p, y) {
            imuX = x; imuY = y; imuZ = z; roll = r; pitch = p; yaw = y;
        }

        function emitFakeBaroData(p, a) {
            pressure = p; altitude = a;
        }

        function emitFakeTelemetryData(v, t, s, b) {
            velocity = v; temperature = t; signal = s; battery = b;
        }
    }

    // Panel_Rocket_Visualization {
    //     id: panel
    // }

    // Panel_IMU_And_Kalman_Data {
    //     id: dataPanel
    // }
    Main {
        id: panel
    }

    function test_all() {
        for (let i = 0; i < 360; i++) {
            sensorData.emitFakeIMUData(i, i, i, i, i, i)
            sensorData.emitFakeTelemetryData(Math.floor(Math.random() * i), Math.floor(Math.random() * i), Math.floor(Math.random() * i), Math.floor(Math.random() * i))
            sensorData.emitFakeBaroData(Math.floor(Math.random() * i), Math.floor(Math.random() * i))
            wait(10)
        }
    }
}
