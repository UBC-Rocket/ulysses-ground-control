import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    //Parameters
    property double velocity
    property double altitude
    property double temperature
    property double signal
    property double battery


    //Initializing the Panel
    id: panel_Telemetry
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
            //Initializing Header for Telemetry Data
            id: header_Telemetry
            color: "#93C5FD"
            text: "Telemetry Data"
            font.pixelSize: 20
            font.bold: true
        }
    }

    Rectangle {
        id: velocity_and_altitude
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: header.height
        anchors.leftMargin: header.anchors.leftMargin
        height: 200

        Rectangle {
            anchors.top: velocity_and_altitude.top
            anchors.left: parent.left
            width: panel_Telemetry.width

            DataBox {
                dataName: "VELOCITY (km/h)"
                dataValue: velocity
                sections: 2
                section_num: 1
            }
            DataBox {
                dataName: "ALTITUDE (m)"
                dataValue: altitude
                sections: 2
                section_num: 2
            }
        }

    }


    Rectangle {
        id: temp_signal_battery
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: header.height + velocity_and_altitude.height
        anchors.leftMargin: header.anchors.leftMargin
        height: 200

        Rectangle {
            anchors.top: temp_signal_battery.top
            anchors.left: parent.left
            width: panel_Telemetry.width;

            DataBox {
                dataName: "TEMP (C)"
                dataValue: temperature
                sections: 3
                section_num: 1
            }
            DataBox {
                dataName: "SIGNAL (%)"
                dataValue: signal
                sections: 3
                section_num: 2
            }
            DataBox {
                dataName: "BATTERY (%)"
                dataValue: battery
                sections: 3
                section_num: 3
            }
        }

    }
}
