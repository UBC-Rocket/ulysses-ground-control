import QtQuick

Rectangle {
    //Initializing the Header
    id: header
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    height: 70
    color: "#111827"

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
            case 1: return "#b63b3b"   // ESTOP — red
            case 2: return "#1e8e61"   // RISE  — green
            case 3: return "#1e8e61"   // HOVER — green
            case 4: return "#cda53a"   // LOWER — amber
            default: return "#6b7280"  // IDLE / UNKNOWN — grey
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
        font.pixelSize: 24
        font.bold: true
        color: "#4a90e2"
    }

    Text {
        id: subtitle

        //Position
        anchors.left: title.left
        y: title.y + title.height
        anchors.leftMargin: title.leftMargin

        //Text
        text: "Ulysses"
        font.pixelSize: 18
        color: "#8892b0"
    }

    // Flight state badge — top-right of header
    Rectangle {
        id: flightStateBadge
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 20
        width: flightStateText.implicitWidth + 24
        height: 32
        radius: 6
        color: header.flightStateColor(downlinkDecoder.flightState)

        Text {
            id: flightStateText
            anchors.centerIn: parent
            text: header.flightStateLabel(downlinkDecoder.flightState)
            font.pixelSize: 16
            font.bold: true
            color: "#ffffff"
        }
    }

    Rectangle {
        id: line

        anchors.bottom: parent.bottom
        color: "#16213e"
        width: parent.width
        height: 2
    }
}
