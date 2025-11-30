// LayoutGrid.qml
import QtQuick
import QtQuick.Layouts

GridLayout {
    id: grid
    columns: 4
    flow: GridLayout.LeftToRight
    rowSpacing: 5
    columnSpacing: 5
    anchors.fill: parent
    anchors.topMargin: 2

    // ───── Row 0 ──────────────────────────────────────────────────────────

    // Panel_Kalma_and_Engine
    Item {
        Layout.row: 0; Layout.column: 0
        Layout.fillWidth: true; Layout.fillHeight: true
        Panel_Kalman_and_Engine {
            anchors.fill: parent
        }
    }

    // Panel_Rocket_Visualization
    Item {
        Layout.row: 0; Layout.column: 1; Layout.columnSpan: 2
        Layout.fillWidth: true; Layout.fillHeight: true
        Panel_Rocket_Visualization { anchors.fill: parent }
    }

    // Panel_Baro_And_Telemetry_Data
    Item {
        Layout.row: 0; Layout.column: 3
        Layout.fillWidth: true; Layout.fillHeight: true
        Panel_Baro_And_Telemetry_Data { anchors.fill: parent }
    }

    // ───── Row 1 ──────────────────────────────────────────────────────────

    // Panel_PID_Slider
    Item {
        Layout.row: 1; Layout.column: 0
        Layout.fillWidth: true; Layout.fillHeight: true
        Panel_PID_Slider { anchors.fill: parent }
    }

    // Panel_Control
    Item {
        Layout.row: 1; Layout.column: 1
        Layout.fillWidth: true; Layout.fillHeight: true
        Panel_Control { anchors.fill: parent }
    }

    // Panel_System_Alert
    Item {
        Layout.row: 1; Layout.column: 2; Layout.columnSpan: 2
        Layout.fillWidth: true; Layout.fillHeight: true
        Panel_System_Alert { anchors.fill: parent }
    }
}


