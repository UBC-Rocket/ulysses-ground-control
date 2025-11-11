import QtQuick

Rectangle {
    id: header

    property string headerText
    property int defaultSize: 1

    height: parent.height/415 * 50
    width: parent.width
    color: "transparent"
    anchors {
        top: parent.top
        left: parent.left
        topMargin: 15
        leftMargin: 15
    }

    property real ratio: Screen.devicePixelRatio

    Text {
        //Initializing Header for the panel
        id: header_Panel
        color: "#93C5FD"
        text: headerText
        font.pixelSize: 12 + Math.floor(header.width/35)/defaultSize
        font.bold: true
    }
}
