import QtQuick
import "Items"

BasePanel {
    id: panel_Kalma_and_Engine

    // Kalman Filter
    property double raw_angle_x: sensorData.rawAngleX
    property double filtered_angle_x: sensorData.filteredAngleX
    property double raw_angle_y: sensorData.rawAngleY
    property double filtered_angle_y: sensorData.filteredAngleY

    // Engine Control (placeholder values can be wired later)
    property double throttle: 0
    property double fuel: 0


    BaseHeader {
        id:header
        headerText: "Kalma Angles and Engine"
    }

    Rectangle {
        id: kalman_angles_x

        height: (parent.height-header.height)/4
        anchors {
            top: parent.top
            left: parent.left
            topMargin: header.height
            leftMargin: header.anchors.leftMargin
        }

        Text {
            id: subheader_angles
            text: "Kalman Angles (deg)"
            font.pixelSize: 18
            color: "#D1D5DB"
            height: 40
            y: 0
        }

        DataBoxList {
            anchors.top: subheader_angles.bottom
            width: panel_Kalma_and_Engine.width;

            size: 2
            dataNames: ["RAW ANGLE X", "FILTERED ANGLE X"]
            dataValues: [raw_angle_x, filtered_angle_x]
        }
    }

    Rectangle {
        id: kalman_angles_y
        height: (parent.height-header.height)/4
        anchors {
            top: kalman_angles_x.bottom
            left: parent.left
            topMargin: header.height
            leftMargin: header.anchors.leftMargin
        }

        DataBoxList {
            width: panel_Kalma_and_Engine.width;

            size: 2
            dataNames: ["RAW ANGLE Y", "FILTERED ANGLE Y"]
            dataValues: [raw_angle_y, filtered_angle_y]
        }
    }

    Rectangle {
        id: engine

        height: (parent.height-header.height)/2
        anchors {
            top: kalman_angles_y.bottom
            left: parent.left
            leftMargin: header.anchors.leftMargin
        }

        Text {
            id: subheader_engine
            text: "Engine Control"
            font.pixelSize: 18
            color: "#D1D5DB"
            height: 40
            y: 0
        }

        DataBoxList {
            anchors.top: subheader_engine.bottom
            width: panel_Kalma_and_Engine.width;

            size: 2
            boxHeight: 70
            dataNames: ["THROTTLE (%)", "FUEL (%)"]
            dataValues: [throttle, fuel]
        }
    }
}
