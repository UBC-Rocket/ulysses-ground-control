import QtQuick
import QtQuick.Controls

Rectangle {

    //Initializing the Panel
    id: testPanel
    color: "yellow"
    border.color: "#2d3748"
    border.width: 4
    radius: 8

    height: (parent.parent.height - 20)/2 - 10
    width: ((parent.parent.width - 20)/4 - 5)

    Text {

        //Initializing Header
        id: header_Test
        color: "#c5dafa"
        text: "Test Panel"
        font.pixelSize: 20
        font.bold: true
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 15
        anchors.leftMargin: 20


    }

}
