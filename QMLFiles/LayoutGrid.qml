// LayoutGrid.qml
import QtQuick
import QtQuick.Layouts
import "Items"
import "Panels"

GridLayout {
    id: grid
    columns: 4
    flow: GridLayout.LeftToRight
    rowSpacing: Theme.gridSpacing
    columnSpacing: Theme.gridSpacing
    anchors.fill: parent
    anchors.topMargin: 2

    // ───── Row 0 ──────────────────────────────────────────────────────────

    // Panel_Angles_And_Engine
    Item {
        Layout.row: 0; Layout.column: 0
        Layout.fillWidth: true; Layout.fillHeight: true
        Panel_Angles_And_Engine {
            anchors.fill: parent
        }
    }

    // Panel_Rocket_Visualization
    Item {
        Layout.row: 0; Layout.column: 1; Layout.columnSpan: 2
        Layout.fillWidth: true; Layout.fillHeight: true
        Panel_Rocket_Visualization { anchors.fill: parent }
    }

    // Panel_State_And_Position
    Item {
        Layout.row: 0; Layout.column: 3
        Layout.fillWidth: true; Layout.fillHeight: true
        Panel_State_And_Position { anchors.fill: parent }
    }

    // ───── Row 1 ──────────────────────────────────────────────────────────

    // Panel_PID_Controller
    Item {
        Layout.row: 1; Layout.column: 0
        Layout.fillWidth: true; Layout.fillHeight: true
        Panel_PID_Controller { anchors.fill: parent }
    }

    // Panel_Control
    Item {
        Layout.row: 1; Layout.column: 1
        Layout.fillWidth: true; Layout.fillHeight: true
        Panel_Control { anchors.fill: parent }
    }

    // Panel_System_Alert
    Item {
        Layout.row: 1; Layout.column: 2
        Layout.fillWidth: true; Layout.fillHeight: true
        Panel_System_Alert { anchors.fill: parent }
    }

    // Panel_System_Health
    Item {
        Layout.row: 1; Layout.column: 3
        Layout.fillWidth: true; Layout.fillHeight: true
        Panel_System_Health { anchors.fill: parent }
    }
}


