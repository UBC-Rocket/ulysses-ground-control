import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    //Parameters
    property double x_axis
    property double y_axis
    property double z_axis
    property double roll
    property double pitch
    property double yaw


    //Initializing the Panel
    id: panel_IMU
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
            //Initializing Header for IMU Data
            id: header_IMU_Data
            color: "#93C5FD"
            text: "IMU Data"
            font.pixelSize: 20
            font.bold: true
        }
    }

    Rectangle {
        id: accelerometer
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: header.height
        anchors.leftMargin: header.anchors.leftMargin
        height: 200

        Text {
            id: subheader_acc
            text: "Accelerometer (m/s^2)"
            font.pixelSize: 18
            color: "#D1D5DB"
            height: 40
            y: 0
        }

        Rectangle {
            anchors.top: subheader_acc.bottom
            anchors.left: parent.left
            width: panel_IMU.width;

            DataBox {
                dataName: "X-AXIS"
                dataValue: x_axis
                sections: 3
                section_num: 1
            }
            DataBox {
                dataName: "Y-AXIS"
                dataValue: y_axis
                sections: 3
                section_num: 2
            }
            DataBox {
                dataName: "Z-AXIS"
                dataValue: z_axis
                sections: 3
                section_num: 3
            }
        }

    }


    Rectangle {
        id: gyroscope
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: header.height + accelerometer.height
        anchors.leftMargin: header.anchors.leftMargin
        height: 200

        Text {
            id: subheader_gyro
            text: "Gyroscope (deg/s)"
            font.pixelSize: 18
            color: "#D1D5DB"
            height: 40
            y: 0
        }

        Rectangle {
            anchors.top: subheader_gyro.bottom
            anchors.left: parent.left
            width: panel_IMU.width;

            DataBox {
                dataName: "ROLL"
                dataValue: roll
                sections: 3
                section_num: 1
            }
            DataBox {
                dataName: "PITCH"
                dataValue: pitch
                sections: 3
                section_num: 2
            }
            DataBox {
                dataName: "YAW"
                dataValue: yaw
                sections: 3
                section_num: 3
            }
        }

    }
}
