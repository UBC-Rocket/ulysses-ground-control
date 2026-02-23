import QtQuick
import "Items"

Rectangle {
    //Initializing the Header
    id: header
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    height: 70
    color: Theme.background

    // Map FlightState enum integer to display string and color.
    // 0=IDLE, 1=ESTOP, 2=RISE, 3=HOVER, 4=LOWER
    function flightStateLabel(state) {
        switch (state) {
            case 0: return "IDLE"
            case 1: return "ESTOP"
            case 2: return "RISE"
            case 3: return "HOVER"
            case 4: return "LOWER"
            default: return "UNKNOWN"
        }
    }

    function flightStateColor(state) {
        switch (state) {
            case 1: return Theme.danger    // ESTOP — red
            case 2: return Theme.success   // RISE  — green
            case 3: return Theme.success   // HOVER — green
            case 4: return Theme.warn      // LOWER — amber
            default: return Theme.textTertiary  // IDLE / UNKNOWN — grey
        }
    }

    Text {
        id: title

        //Position
        anchors.left: parent.left
        y: parent.height/14
        anchors.leftMargin: 20

        //Text
        text: "Rocket Ground Control"
        font.family: Theme.fontFamily
        font.pixelSize: 24
        font.bold: true
        color: Theme.accent
    }

    Text {
        id: subtitle

        //Position
        anchors.left: title.left
        y: title.y + title.height
        anchors.leftMargin: title.leftMargin

        //Text
        text: "Ulysses"
        font.family: Theme.fontFamily
        font.pixelSize: 18
        color: Theme.textSecondary
    }

    // Flight state badge — top-right of header
    Rectangle {
        id: flightStateBadge
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 20
        width: flightStateText.implicitWidth + 24
        height: 32
        radius: Theme.radiusPanel
        color: header.flightStateColor(sensorData.flightState)

        Text {
            id: flightStateText
            anchors.centerIn: parent
            text: header.flightStateLabel(sensorData.flightState)
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontH2
            font.bold: true
            color: Theme.textPrimary
        }
    }

    Rectangle {
        id: line

        anchors.bottom: parent.bottom
        color: Theme.divider
        width: parent.width
        height: 1
    }
}
