import QtQuick

Rectangle {
    //Parameters
    property double throttle
    property double fuel

    //Initializing the Panel
    id: panel_Engine
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
            //Initializing Header for Engine
            id: header_Engine
            color: "#93C5FD"
            text: "Engine Control"
            font.pixelSize: 20
            font.bold: true
        }
    }

    Rectangle {

        id: throttle_and_fuel
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: header.height
        anchors.leftMargin: header.anchors.leftMargin
        height: 200

        Rectangle {
            anchors.top: throttle_and_fuel.top
            anchors.left: parent.left
            width: panel_Engine.width;

            DataBox {
                dataName: "THROTTLE (%)"
                dataValue: throttle
                sections: 2
                section_num: 1
                height: 70
            }
            DataBox {
                dataName: "FUEL (%)"
                dataValue: fuel
                sections: 2
                section_num: 2
                height: 70
            }

        }

    }


}
