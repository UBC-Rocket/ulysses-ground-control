import QtQuick
import QtQuick.Controls

Component {
    id: cmdCard
    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusCard
        border.width: Theme.strokeControl
        border.color: Theme.accentMuted        // Visual affordance to indicate clickability.
        color: hovered ? Theme.accentSubtle : Theme.surfaceInset // Hover feedback without relayout.

        property string title: ""       // User-facing name of the command (e.g., "Hover").
        property string cmd: ""         // Actual single-letter code to emit (e.g., "H").

        readonly property bool hovered: ma.containsMouse // Centralized hover state for styling.
        Behavior on color { ColorAnimation { duration: Theme.transitionFast } } // Smooth hover color transition.
        Behavior on scale { NumberAnimation { duration: 90 } } // Brief press/release animation.

        // --- Text stack: shows the command name and a short hint with the code to be sent ---
        Column {
            id: labelCol
            anchors.centerIn: parent
            spacing: 6
            width: parent.width * 0.82

            Text {
                text: title
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 18
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                width: parent.width
            }

            Text {
                text: 'sends "' + cmd + '"' // Secondary hint: shows the code that will be sent.
                color: Theme.textSecondary
                font.family: Theme.fontFamily
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
            border.color: Theme.accentMuted
            opacity: 0.20
        }

        // --- Mouse handler: emits the panel's signal with this card's code when clicked ---
        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            onPressed: parent.scale = 0.985 // Tactile press effect (shrinks slightly).
            onReleased: parent.scale = 1.0  // Reset scale on release.
            onClicked: control_panel.commandTriggered(txWhich, cmd) // Raise event upward with payload.
        }
    }
}
