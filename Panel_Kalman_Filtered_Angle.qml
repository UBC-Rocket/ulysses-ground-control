import QtQuick

Rectangle {
    //Parameters
    property double raw_angle
    property double filtered_angle

    //Initializing the Panel
    id: panel_Kalman
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
            //Initializing Header for Kalman
            id: header_Kalman
            color: "#93C5FD"
            text: "Kalman Filtered Data"
            font.pixelSize: 20
            font.bold: true
        }
    }

    Rectangle {

        id: angles
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: header.height
        anchors.leftMargin: header.anchors.leftMargin
        height: 200

        Text {
            id: subheader_angles
            text: "Angles (deg)"
            font.pixelSize: 18
            color: "#D1D5DB"
            height: 40
            y: 0
        }

        Rectangle {
            anchors.top: subheader_angles.bottom
            anchors.left: parent.left
            width: panel_Kalman.width;

            DataBox {
                dataName: "RAW ANGLE"
                dataValue: raw_angle
                sections: 2
                section_num: 1
                height: 70
            }
            DataBox {
                dataName: "FILTERED ANGLE"
                dataValue: filtered_angle
                sections: 2
                section_num: 2
                height: 70
            }

        }

    }


}
