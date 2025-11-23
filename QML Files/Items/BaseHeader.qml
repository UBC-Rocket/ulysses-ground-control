import QtQuick

Rectangle {
    id: header

    property string headerText

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
        color: "#93C5FD"
        text: headerText
        font.pixelSize: 20
        font.bold: true
    }
}
