import QtQuick
import "Items"

BasePanel {
    id: panel_IMU_and_Kalman

    //Parameters from IMU
    property double x_axis
    property double y_axis
    property double z_axis
    property double roll
    property double pitch
    property double yaw

    //Parameters from Kalman
    property double raw_angle
    property double filtered_angle


    BaseHeader {
        id:header
        headerText: "IMU and Kalman Data"
    }

    Rectangle {
        id: accelerometer

        height: (parent.height-header.height)/3
        anchors {
            top: parent.top
            left: parent.left
            topMargin: header.height
            leftMargin: header.anchors.leftMargin
        }

        Text {
            id: subheader_acc
            text: "Accelerometer (m/s^2)"
            font.pixelSize: 18
            color: "#D1D5DB"
            height: 40
            y: 0
        }

        DataBoxList {
            anchors.top: subheader_acc.bottom
            width: panel_IMU_and_Kalman.width;

            size: 3
            dataNames: ["X-AXIS", "Y-AXIS", "Z-AXIS"]
            dataValues: [100,200,300]
        }
    }

    Rectangle {
        id: gyroscope

        height: (parent.height-header.height)/3
        anchors {
            top: accelerometer.bottom
            left: parent.left
            leftMargin: header.anchors.leftMargin
        }

        Text {
            id: subheader_gyro
            text: "Gyroscope (deg/s)"
            font.pixelSize: 18
            color: "#D1D5DB"
            height: 40
            y: 0
        }

        DataBoxList {
            anchors.top: subheader_gyro.bottom
            width: panel_IMU_and_Kalman.width;

            size: 3
            dataNames: ["ROLL", "PITCH", "YAW"]
            dataValues: [1,2,3]
        }
    }

    Rectangle {
        id: kalman_angles

        height: (parent.height-header.height)/3
        anchors {
            top: gyroscope.bottom
            left: parent.left
            leftMargin: header.anchors.leftMargin
        }

        Text {
            id: subheader_angles
            text: "Angles (deg)"
            font.pixelSize: 18
            color: "#D1D5DB"
            height: 40
            y: 0
        }

        DataBoxList {
            anchors.top: subheader_angles.bottom
            width: panel_IMU_and_Kalman.width;

            size: 2
            dataNames: ["RAW ANGLE", "FILTERED ANGLE"]
            dataValues: [raw_angle, filtered_angle]
        }
    }
}
