import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Items"

BasePanel {
    id: control_panel
    property int txWhich: 1
    signal commandTriggered(int which, string code) // Public signal: emitted when a command card is clicked; parent can handle it.

    // --- Header area: static title for the command section ---
    BaseHeader {
        id:header
        headerText: "Command Controls"
    }

    // --- Card grid: container that lays out interactive command tiles in 2 columns ---
    GridLayout {
        id: cards
        anchors {
            top: header.bottom; topMargin: 12
            left: parent.left; right: parent.right; bottom: parent.bottom
            leftMargin: 16; rightMargin: 16; bottomMargin: 16
        }
        columns: 2
        rowSpacing: 16
        columnSpacing: 16

        // --- Reusable command card component: displays a title and the code it sends ---
        CommandCard {
            id: cmdCard
        }

        // --- Four grid items below instantiate the reusable card with different title/code pairs ---

        // Card 1: Hover -> "H"
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Loader {
                anchors.fill: parent
                sourceComponent: cmdCard
                onLoaded: { item.title = "Arm"; item.cmd = 1 } // Initialize instance properties.
            }
        }

        // Card 2: Fly Up -> "U"
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Loader {
                anchors.fill: parent
                sourceComponent: cmdCard
                onLoaded: { item.title = "Launch"; item.cmd = 2 }
            }
        }

        // Card 3: Fly Down -> "D"
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Loader {
                anchors.fill: parent
                sourceComponent: cmdCard
                onLoaded: { item.title = "Abort"; item.cmd = 3 }
            }
        }

        // Card 4: Idle -> "I"
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Loader {
                anchors.fill: parent
                sourceComponent: cmdCard
                onLoaded: { item.title = "Land"; item.cmd = 4 }
            }
        }
    }

    // --- Signal wiring: when a card is clicked, forward the code to the C++ CommandSender object ---
    Connections {
        target: control_panel
        function onCommandTriggered(txWhich, code) {
            commandsender.sendFlightCommand(txWhich, code) // Delegate to Q_INVOKABLE; panel stays transport-agnostic.
        }
    }
}
