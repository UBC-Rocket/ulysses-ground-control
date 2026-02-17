import QtQuick
import "Items"

BasePanel {
    id: panel_Kalman_and_Engine

    // ===== Spacing controls =====
    property real sectionSpacing: 6                      // spacing between sections (X->Y->Z->Engine)
    property real headerToFirstSectionSpacing: 2         // main title -> "Kalman Angles (deg)" section
    property real subheaderToDataSpacing: 12             // "Kalman Angles (deg)" -> X boxes, "Engine Control" -> boxes
    property real rowPadding: 4                          // extra padding you were using for implicitHeight (kept)

    // Kalman Filter
    property double raw_angle_x: sensorData.rawAngleX
    property double filtered_angle_x: sensorData.filteredAngleX
    property double raw_angle_y: sensorData.rawAngleY
    property double filtered_angle_y: sensorData.filteredAngleY
    property double raw_angle_z: sensorData.rawAngleZ
    property double filtered_angle_z: sensorData.filteredAngleZ

    // Engine Control (placeholder values can be wired later)
    property double throttle: 0
    property double fuel: 0

    BaseHeader {
        id: header
        headerText: "Kalman Angles and Engine"
    }

    Rectangle {
        id: kalman_angles_x
        color: "transparent"

        // include spacing between subheader and dataBoxListX
        implicitHeight: subheader_angles.implicitHeight
                        + panel_Kalman_and_Engine.subheaderToDataSpacing
                        + dataBoxListX.height
        height: implicitHeight

        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right

            // decrease spacing between main title and this section
            topMargin: panel_Kalman_and_Engine.headerToFirstSectionSpacing

            leftMargin: header.anchors.leftMargin
            rightMargin: header.anchors.leftMargin
        }

        Text {
            id: subheader_angles
            text: "Kalman Angles (deg)"
            font.pixelSize: 18
            color: "#D1D5DB"
            y: 0
        }

        DataBoxList {
            id: dataBoxListX
            anchors.top: subheader_angles.bottom

            // increase spacing between "Kalman Angles (deg)" and X angle boxes
            anchors.topMargin: panel_Kalman_and_Engine.subheaderToDataSpacing

            width: parent.width

            size: 2
            dataNames: ["RAW X", "FILTERED X"]
            dataValues: [raw_angle_x, filtered_angle_x]
        }
    }

    Rectangle {
        id: kalman_angles_y
        color: "transparent"
        implicitHeight: dataBoxListY.height + panel_Kalman_and_Engine.rowPadding
        height: implicitHeight

        anchors {
            top: kalman_angles_x.bottom
            left: parent.left
            right: parent.right
            topMargin: panel_Kalman_and_Engine.sectionSpacing
            leftMargin: header.anchors.leftMargin
            rightMargin: header.anchors.leftMargin
        }

        DataBoxList {
            id: dataBoxListY
            width: parent.width

            size: 2
            dataNames: ["RAW Y", "FILTERED Y"]
            dataValues: [raw_angle_y, filtered_angle_y]
        }
    }

    Rectangle {
        id: kalman_angles_z
        color: "transparent"
        implicitHeight: dataBoxListZ.height + panel_Kalman_and_Engine.rowPadding
        height: implicitHeight

        anchors {
            top: kalman_angles_y.bottom
            left: parent.left
            right: parent.right
            topMargin: panel_Kalman_and_Engine.sectionSpacing
            leftMargin: header.anchors.leftMargin
            rightMargin: header.anchors.leftMargin
        }

        DataBoxList {
            id: dataBoxListZ
            width: parent.width

            size: 2
            dataNames: ["RAW Z", "FILTERED Z"]
            dataValues: [raw_angle_z, filtered_angle_z]
        }
    }

    Rectangle {
        id: engine
        color: "transparent"

        // include spacing between subheader and engine databoxes
        implicitHeight: subheader_engine.implicitHeight
                        + panel_Kalman_and_Engine.subheaderToDataSpacing
                        + dataBoxListEngine.height
        height: implicitHeight

        anchors {
            top: kalman_angles_z.bottom
            left: parent.left
            right: parent.right
            topMargin: panel_Kalman_and_Engine.sectionSpacing
            leftMargin: header.anchors.leftMargin
            rightMargin: header.anchors.leftMargin
        }

        Text {
            id: subheader_engine
            text: "Engine Control"
            font.pixelSize: 18
            color: "#D1D5DB"
            y: 0
        }

        DataBoxList {
            id: dataBoxListEngine
            anchors.top: subheader_engine.bottom

            // increase spacing between "Engine Control" and its data boxes
            anchors.topMargin: panel_Kalman_and_Engine.subheaderToDataSpacing

            width: parent.width

            size: 2
            boxHeight: 50
            dataNames: ["THROTTLE (%)", "FUEL (%)"]
            dataValues: [throttle, fuel]
        }
    }
}
