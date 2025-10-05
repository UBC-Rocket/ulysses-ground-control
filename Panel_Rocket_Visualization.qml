import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    //Parameters

    //Initializing the Panel
    id: panel_Rocket_Visualization
    color: "#1F2937"
    border.color: "#2d3748"
    border.width: 4
    radius: 8
    height: (parent.parent.height - 20)/2 - 10
    width: (parent.parent.width - 20)/4 - 5


    Rectangle {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 15
        anchors.leftMargin: 15
        height: 50
        Text {
            //Initializing Header for Rocket Visualization
            id: header_Rocket_Visualization
            color: "#93C5FD"
            text: "Rocket Visualization"
            font.pixelSize: 20
            font.bold: true
        }
    }

    Rectangle {


    }
}
