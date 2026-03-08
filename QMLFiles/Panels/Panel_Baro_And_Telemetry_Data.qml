import QtQuick
import "Items"

BasePanel {
    id: panel_Baro_And_Telemetry

    // Position
    property double posX: sensorData.posX
    property double posY: sensorData.posY
    property double altitude: sensorData.altitude

    // Telemetry
    property double velocity: sensorData.velocity

    // Link stats
    property double radioRx: sensorData.radioRxCount
    property double radioTx: sensorData.radioTxCount

    BaseHeader {
        id:header
        headerText: "State & Position Data"
    }

    Rectangle {
        id: position_xy
        color: "transparent"
        height: (parent.height-header.height)/3
        anchors {
            top: parent.top
            left: parent.left
            topMargin: header.height
            leftMargin: header.anchors.leftMargin
        }

        DataBoxList {
            anchors.top: position_xy.top
            width: panel_Baro_And_Telemetry.width;

            size: 2
            boxHeight: 56
            dataNames: ["POS X (m)", "POS Y (m)"]
            dataValues: [posX, posY]
        }
    }

    Rectangle {
        id: altitude_and_velocity
        color: "transparent"
        height: (parent.height-header.height)/3
        anchors {
            top: position_xy.bottom
            left: parent.left
            leftMargin: header.anchors.leftMargin
        }

        DataBoxList {
            anchors.top: altitude_and_velocity.top
            width: panel_Baro_And_Telemetry.width;

            size: 2
            boxHeight: 56
            dataNames: ["ALTITUDE (m)", "VELOCITY (km/h)"]
            dataValues: [altitude, velocity]
        }
    }

    Rectangle {
        id: radio_stats
        color: "transparent"
        height: (parent.height-header.height)/3
        anchors {
            top: altitude_and_velocity.bottom
            left: parent.left
            leftMargin: header.anchors.leftMargin
        }

        DataBoxList {
            anchors.top: radio_stats.top
            width: panel_Baro_And_Telemetry.width;

            size: 2
            boxHeight: 56
            dataNames: ["RADIO RX", "RADIO TX"]
            dataValues: [radioRx, radioTx]
        }
    }
}
