import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "Items"

BasePanel {
    id: panel_Control

    signal commandTriggered(string code) // Public signal: emitted when a command card is clicked; parent can handle it.

    // --- Header area: static title for the command section ---
    BaseHeader {
        id:header
        headerText: "Command Control"
    }

    // --- Card grid: container that lays out interactive command tiles in 2 columns ---
    GridLayout {
        id: cards
        anchors {
            top: header.bottom; bottom: parent.bottom
            left: parent.left; right: parent.right
            topMargin: 12; leftMargin: 16
            rightMargin: 16; bottomMargin: 16
        }
        columns: 2
        rowSpacing: 16
        columnSpacing: 16

        // --- Reusable command card component: displays a title and the code it sends ---
        Component {
            id: cmdCard

            Rectangle {
                anchors.fill: parent
                radius: 18
                border.width: 2
                border.color: "#5FA8FF"        // Visual affordance to indicate clickability.
                color: hovered ? "#162133" : "#111827" // Hover feedback without relayout.

                property string title: ""       // User-facing name of the command (e.g., "Hover").
                property string cmd: ""         // Actual single-letter code to emit (e.g., "H").

                readonly property bool hovered: ma.containsMouse // Centralized hover state for styling.
                Behavior on color { ColorAnimation { duration: 120 } } // Smooth hover color transition.
                Behavior on scale { NumberAnimation { duration: 90 } } // Brief press/release animation.

                // --- Text stack: shows the command name and a short hint with the code to be sent ---
                Column {
                    id: labelCol
                    anchors.centerIn: parent
                    spacing: 6
                    width: parent.width * 0.82

                    Text {
                        text: title
                        color: "#DCE7F5"
                        font.pixelSize: 18
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                    Text {
                        text: 'sends "' + cmd + '"' // Secondary hint: shows the code that will be sent.
                        color: "#9AA7B7"
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                }

                // --- Subtle inner outline: aesthetic highlight to match the panel style ---
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: "transparent"
                    border.width: 1
                    border.color: "#7BB6FF"
                    opacity: 0.35
                }

                // --- Mouse handler: emits the panel’s signal with this card’s code when clicked ---
                MouseArea {
                    id: ma
                    anchors.fill: parent
                    hoverEnabled: true
                    onPressed: parent.scale = 0.985 // Tactile press effect (shrinks slightly).
                    onReleased: parent.scale = 1.0  // Reset scale on release.
                    onClicked: panel_Control.commandTriggered(cmd) // Raise event upward with payload.
                }
            }
        }

        // --- Four grid items below instantiate the reusable card with different title/code pairs ---

        // Card 1: Hover -> "H"
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Loader {
                anchors.fill: parent
                sourceComponent: cmdCard
                onLoaded: { item.title = "Hover";    item.cmd = "H" } // Initialize instance properties.
            }
        }

        // Card 2: Fly Up -> "U"
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Loader {
                anchors.fill: parent
                sourceComponent: cmdCard
                onLoaded: { item.title = "Fly Up";   item.cmd = "U" }
            }
        }

        // Card 3: Fly Down -> "D"
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Loader {
                anchors.fill: parent
                sourceComponent: cmdCard
                onLoaded: { item.title = "Fly Down"; item.cmd = "D" }
            }
        }

        // Card 4: Idle -> "I"
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Loader {
                anchors.fill: parent
                sourceComponent: cmdCard
                onLoaded: { item.title = "Idle";     item.cmd = "I" }
            }
        }
    }

    // --- Signal wiring: when a card is clicked, forward the code to the C++ CommandSender object ---
    Connections {
        target: panel_Control
        function onCommandTriggered(code) {
            commandsender.sendCode(code) // Delegate to Q_INVOKABLE; panel stays transport-agnostic.
        }
    }

}






