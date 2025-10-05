import QtQuick

Rectangle {
    //Parameters
    property double pressure
    property double altitude

    //Initializing the Panel
    id: panel_Baro
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
            //Initializing Header for Baro
            id: header_Baro
            color: "#93C5FD"
            text: "Barometric Data"
            font.pixelSize: 20
            font.bold: true
        }
    }

    Rectangle {

        id: pressure_and_altitude
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: header.height
        anchors.leftMargin: header.anchors.leftMargin
        height: 200

        Rectangle {
            anchors.top: pressure_and_altitude.top
            anchors.left: parent.left
            width: panel_Baro.width;

            DataBox {
                dataName: "PRESSURE (hPa)"
                dataValue: pressure
                sections: 2
                section_num: 1
                height: 70
            }
            DataBox {
                dataName: "ALTITUDE (m)"
                dataValue: altitude
                sections: 2
                section_num: 2
                height: 70
            }

        }

    }


}
