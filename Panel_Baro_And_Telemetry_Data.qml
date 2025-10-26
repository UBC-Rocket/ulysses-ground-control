import QtQuick
import "Items"

BasePanel {
    id: panel_Baro_And_Telemetry

    //Barometer Data
    property double pressure
    property double altitude

    //Telemetry Data
    property double velocity
    property double temperature
    property double signals
    property double battery

    BaseHeader {
        id:header
        headerText: "Barometric and Telemetry Data"
    }

    Rectangle {
        id: pressure_and_altitude

        height: (parent.height-header.height)/3
        anchors {
            top: parent.top
            left: parent.left
            topMargin: header.height
            leftMargin: header.anchors.leftMargin
        }

        DataBoxList {
            anchors.top: pressure_and_altitude.top
            width: panel_Baro_And_Telemetry.width;

            size: 2
            boxHeight: 50
            dataNames: ["PRESSURE (hPa)", "ALTITUDE (m)"]
            dataValues: [pressure, altitude]
        }
    }

    Rectangle {
        id: velocity_and_temp

        height: (parent.height-header.height)/3
        anchors {
            top: pressure_and_altitude.bottom
            left: parent.left
            leftMargin: header.anchors.leftMargin
        }

        DataBoxList {
            anchors.top: velocity_and_temp.top
            width: panel_Baro_And_Telemetry.width;

            size: 2
            boxHeight: 50
            dataNames: ["VELOCITY (km/h)", "TEMP (C)"]
            dataValues: [velocity, temperature]
        }
    }

    Rectangle {
        id: signal_and_battery

        height: (parent.height-header.height)/3
        anchors {
            top: velocity_and_temp.bottom
            left: parent.left
            leftMargin: header.anchors.leftMargin
        }

        DataBoxList {
            anchors.top: signal_and_battery.top
            width: panel_Baro_And_Telemetry.width;

            size: 2
            boxHeight: 50
            dataNames: ["SIGNAL (%)", "BATTERY (%)"]
            dataValues: [signals, battery]
        }
    }

}
