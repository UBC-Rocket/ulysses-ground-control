import QtQuick
import QtQuick.Layouts
import "Items"
import "Panels"

GridLayout {
    id: grid

    property int resolution: 50

    columns: 1 + 4 * resolution
    rows: 1 + 2 * resolution
    flow: GridLayout.LeftToRight
    rowSpacing: height/(rows-1)
    columnSpacing: width/(columns-1)
    anchors.fill: parent
    anchors.topMargin: 2

    property var filled: []

    function init() {
        const a = []
        for(let r = 0; r < rows; r++) {
            const row = []
            for(let c = 0; c < columns; c++) {
                row.push(1)
            }
            a.push(row)
        }
        filled = a
    }

    function markRect(target, val) {
        const r0 = target.Layout.row
        const c0 = target.Layout.column
        const rh = target.Layout.rowSpan
        const cw = target.Layout.columnSpan
        for (let r = Math.max(0, r0); r < Math.min(rows, r0 + rh); ++r)
            for (let c = Math.max(0, c0); c < Math.min(columns, c0 + cw); ++c)
                filled[r][c] = val
    }

    function initT(target)  { markRect(target, 1) }
    function clearT(target) { markRect(target, 0) }

    Component.onCompleted: {
        init()
    }

    function isOccupied(row, col) {
        return filled[row][col] === 1
    }

    // ───── Row 0 ──────────────────────────────────────────────────────────

    // Panel_IMU_And_Kalman_Data
    Item {
        id: panel_IMU_And_Kalman_Data

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
            minimumWidth: resolution * 3/5
            minimumHeight: resolution * 4/5
        }
    }

    // Panel_Rocket_Visualization
    Item {
        id: panel_Rocket_Visualization

        Layout.row: 0 * resolution; Layout.column: 1 * resolution;
        Layout.rowSpan: 1 * resolution; Layout.columnSpan: 2 * resolution;
        Layout.fillWidth: true; Layout.fillHeight: true
        Panel_Rocket_Visualization { anchors.fill: parent }

        BaseResize {
            grid: grid
            panel: parent
            minimumWidth: resolution * 5/10
            minimumHeight: resolution * 3/5
        }
    }

    // Panel_Baro_And_Telemetry_Data
    Item {
        id: panel_Baro_And_Telemetry_Data

        Layout.row: 0 * resolution; Layout.column: 3 * resolution;
        Layout.rowSpan: 1 * resolution; Layout.columnSpan: 1 * resolution;
        Layout.fillWidth: true; Layout.fillHeight: true
        Panel_Baro_And_Telemetry_Data { anchors.fill: parent }

        BaseResize {
            grid: grid
            panel: parent
            minimumWidth: resolution * 3/5
            minimumHeight: resolution * 4/5
        }
    }

    // ───── Row 1 ──────────────────────────────────────────────────────────

    // Panel_Engine_Control
    Item {
        id: panel_Engine_Control

        Layout.row: 1 * resolution; Layout.column: 0 * resolution;
        Layout.rowSpan: 1 * resolution; Layout.columnSpan: 1 * resolution;
        Layout.fillWidth: true; Layout.fillHeight: true
        Panel_Engine_Control { anchors.fill: parent }

        BaseResize {
            grid: grid
            panel: parent
            minimumWidth: resolution * 3/5
            minimumHeight: resolution * 3/5
        }
    }

    // Panel_Control
    Item {
        id: panel_Control

        Layout.row: 1 * resolution; Layout.column: 1 * resolution;
        Layout.rowSpan: 1 * resolution; Layout.columnSpan: 1 * resolution;
        Layout.fillWidth: true; Layout.fillHeight: true
        Panel_Control { anchors.fill: parent }

        BaseResize {
            grid: grid
            panel: parent
            minimumWidth: resolution * 3/5
            minimumHeight: resolution * 3/5
        }
    }

    // Panel_System_Alert
    Item {
        id: panel_System_Alert

        Layout.row: 1 * resolution; Layout.column: 2 * resolution;
        Layout.rowSpan: 1 * resolution; Layout.columnSpan: 2 * resolution;
        Layout.fillWidth: true; Layout.fillHeight: true
        Panel_System_Alert { anchors.fill: parent }

        BaseResize {
            grid: grid
            panel: parent
            minimumWidth: resolution * 3/5
            minimumHeight: resolution * 3/5
        }
    }

    // For Resizing Purpose
    Repeater {
        model: columns
        delegate: Item {
            Layout.row: rows-1; Layout.column: index; Layout.columnSpan: 1;
            Panel_Test { anchors.fill: parent }
        }
    }

    Repeater {
        model: rows
        delegate: Item {
            Layout.column: columns-1; Layout.row: index; Layout.rowSpan: 1;
            Panel_Test { anchors.fill: parent }
        }
    }
}



