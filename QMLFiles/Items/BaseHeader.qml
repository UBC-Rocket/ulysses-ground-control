import QtQuick

Rectangle {
    id: header

    property string headerText
    color: "transparent"

    height: 50
    anchors {
        top: parent.top
        left: parent.left
        topMargin: 15
        leftMargin: 15
    }

    Text {
        //Initializing Header for the panel
        id: header_Panel
        color: Theme.accent
        text: headerText
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontH1
        font.bold: true
    }
}
