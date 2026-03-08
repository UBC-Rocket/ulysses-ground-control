import QtQuick
import "../Items"

BasePanel {
    id: panel_Angles_And_Engine

    // ===== Spacing controls =====
    property real sectionSpacing: 6                      // spacing between sections (X->Y->Z->Engine)
    property real headerToFirstSectionSpacing: 2         // main title -> "Angles" section
    property real subheaderToDataSpacing: 12             // subheader -> data boxes
    property real rowPadding: 4                          // extra padding for implicitHeight

    // Angular rates (deg/s) — raw gyro output
    property double raw_angle_x: sensorData.rawAngleX
    property double raw_angle_y: sensorData.rawAngleY
    property double raw_angle_z: sensorData.rawAngleZ

    // Euler angles (deg) — from attitude quaternion
    property double filtered_angle_x: sensorData.filteredAngleX
    property double filtered_angle_y: sensorData.filteredAngleY
    property double filtered_angle_z: sensorData.filteredAngleZ

    // Engine outputs from telemetry
    property double thrustCmd: sensorData.thrustCmd
    property double gimbalX:   sensorData.gimbalX
    property double gimbalY:   sensorData.gimbalY

    BaseHeader {
        id: header
        headerText: "Angles and Engine"
    }

    Rectangle {
        id: kalman_angles_x
        color: "transparent"

        implicitHeight: subheader_angles.implicitHeight
                        + panel_Angles_And_Engine.subheaderToDataSpacing
                        + dataBoxListX.height
        height: implicitHeight

        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            topMargin: panel_Angles_And_Engine.headerToFirstSectionSpacing
            leftMargin: header.anchors.leftMargin
            rightMargin: header.anchors.leftMargin
        }

        Text {
            id: subheader_angles
            text: "Attitude (deg) / Angular Rate (°/s)"
            font.family: Theme.fontFamily
            font.pixelSize: 18
            color: Theme.textSecondary
            y: 0
        }

        DataBoxList {
            id: dataBoxListX
            anchors.top: subheader_angles.bottom
            anchors.topMargin: panel_Angles_And_Engine.subheaderToDataSpacing
            width: parent.width

            size: 2
            boxHeight: 56
            dataNames: ["ANG RATE X (°/s)", "ROLL (°)"]
            dataValues: [raw_angle_x, filtered_angle_x]
        }
    }

    Rectangle {
        id: kalman_angles_y
        color: "transparent"
        implicitHeight: dataBoxListY.height + panel_Angles_And_Engine.rowPadding
        height: implicitHeight

        anchors {
            top: kalman_angles_x.bottom
            left: parent.left
            right: parent.right
            topMargin: panel_Angles_And_Engine.sectionSpacing
            leftMargin: header.anchors.leftMargin
            rightMargin: header.anchors.leftMargin
        }

        DataBoxList {
            id: dataBoxListY
            width: parent.width

            size: 2
            boxHeight: 56
            dataNames: ["ANG RATE Y (°/s)", "PITCH (°)"]
            dataValues: [raw_angle_y, filtered_angle_y]
        }
    }

    Rectangle {
        id: kalman_angles_z
        color: "transparent"
        implicitHeight: dataBoxListZ.height + panel_Angles_And_Engine.rowPadding
        height: implicitHeight

        anchors {
            top: kalman_angles_y.bottom
            left: parent.left
            right: parent.right
            topMargin: panel_Angles_And_Engine.sectionSpacing
            leftMargin: header.anchors.leftMargin
            rightMargin: header.anchors.leftMargin
        }

        DataBoxList {
            id: dataBoxListZ
            width: parent.width

            size: 2
            boxHeight: 56
            dataNames: ["ANG RATE Z (°/s)", "YAW (°)"]
            dataValues: [raw_angle_z, filtered_angle_z]
        }
    }

    Rectangle {
        id: engine
        color: "transparent"

        implicitHeight: subheader_engine.implicitHeight
                        + panel_Angles_And_Engine.subheaderToDataSpacing
                        + dataBoxListEngine.height
        height: implicitHeight

        anchors {
            top: kalman_angles_z.bottom
            left: parent.left
            right: parent.right
            topMargin: panel_Angles_And_Engine.sectionSpacing
            leftMargin: header.anchors.leftMargin
            rightMargin: header.anchors.leftMargin
        }

        Text {
            id: subheader_engine
            text: "Engine Control"
            font.family: Theme.fontFamily
            font.pixelSize: 18
            color: Theme.textSecondary
            y: 0
        }

        DataBoxList {
            id: dataBoxListEngine
            anchors.top: subheader_engine.bottom
            anchors.topMargin: panel_Angles_And_Engine.subheaderToDataSpacing
            width: parent.width

            size: 3
            boxHeight: 56
            dataNames: ["THRUST", "GIMBAL X", "GIMBAL Y"]
            dataValues: [thrustCmd, gimbalX, gimbalY]
        }
    }
}
