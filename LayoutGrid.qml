import QtQuick
import QtQuick.Layouts
import "Items"

GridLayout {
    id: grid

    property int resolution: 50

    columns: 1 + 4 * resolution
    rows: 1 + 2 * resolution
    flow: GridLayout.LeftToRight
    rowSpacing: height/(rows-1)
    columnSpacing: width/(colums-1)
    anchors.fill: parent
    anchors.topMargin: 2

    // ───── Row 0 ──────────────────────────────────────────────────────────

    // Panel_IMU_And_Kalman_Data
    Item {
        Layout.row: 0 * resolution; Layout.column: 0 * resolution;
        Layout.rowSpan: 1 * resolution; Layout.columnSpan: 1 * resolution;
        Layout.fillWidth: true; Layout.fillHeight: true

        Panel_IMU_And_Kalman_Data {
            anchors.fill: parent

            // IMU demo values
            x_axis: 10; y_axis: 11; z_axis: 12
            roll: 20; pitch: 30; yaw: 40
            raw_angle: 10; filtered_angle: 20
        }

        BaseResize {
            grid: grid
            panel: parent
        }
    }

    // Panel_Rocket_Visualization
    Item {
        Layout.row: 0 * resolution; Layout.column: 1 * resolution;
        Layout.rowSpan: 1 * resolution; Layout.columnSpan: 2 * resolution;
        Layout.fillWidth: true; Layout.fillHeight: true
        Panel_Rocket_Visualization { anchors.fill: parent }

        BaseResize {
            grid: grid
            panel: parent
        }
    }

    // Panel_Baro_And_Telemetry_Data
    Item {
        Layout.row: 0 * resolution; Layout.column: 3 * resolution;
        Layout.rowSpan: 1 * resolution; Layout.columnSpan: 1 * resolution;
        Layout.fillWidth: true; Layout.fillHeight: true
        Panel_Baro_And_Telemetry_Data { anchors.fill: parent }

        BaseResize {
            grid: grid
            panel: parent
        }
    }

    // ───── Row 1 ──────────────────────────────────────────────────────────

    // Panel_Engine_Control
    Item {
        Layout.row: 1 * resolution; Layout.column: 0 * resolution;
        Layout.rowSpan: 1 * resolution; Layout.columnSpan: 1 * resolution;
        Layout.fillWidth: true; Layout.fillHeight: true
        Panel_Engine_Control { anchors.fill: parent }

        BaseResize {
            grid: grid
            panel: parent
        }
    }

    // Panel_Control
    Item {
        Layout.row: 1 * resolution; Layout.column: 1 * resolution;
        Layout.rowSpan: 1 * resolution; Layout.columnSpan: 1 * resolution;
        Layout.fillWidth: true; Layout.fillHeight: true
        Panel_Control { anchors.fill: parent }

        BaseResize {
            grid: grid
            panel: parent
        }
    }

    // Panel_System_Alert
    Item {
        Layout.row: 1 * resolution; Layout.column: 2 * resolution;
        Layout.rowSpan: 1 * resolution; Layout.columnSpan: 2 * resolution;
        Layout.fillWidth: true; Layout.fillHeight: true
        Panel_System_Alert { anchors.fill: parent }

        BaseResize {
            grid: grid
            panel: parent
        }
    }

    // For Resizing Purpose
    Repeater {
        model: columns
        delegate: Item {
            Layout.row: rows; Layout.column: index; Layout.columnSpan: 1;
            Panel_Test { anchors.fill: parent }
        }
    }

    Repeater {
        model: rows
        delegate: Item {
            Layout.column: columns; Layout.row: index; Layout.rowSpan: 1;
            Panel_Test { anchors.fill: parent }
        }
    }
}



