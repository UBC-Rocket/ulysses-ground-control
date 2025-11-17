import QtQuick
import "Items"

BasePanel {
    id: panel_IMU_and_Kalman

    // IMU - Accelerometer
    property double x_axis: sensorData.imuX
    property double y_axis: sensorData.imuY
    property double z_axis: sensorData.imuZ
    
    // IMU - Gyroscope
    property double roll: sensorData.roll
    property double pitch: sensorData.pitch
    property double yaw: sensorData.yaw

    // Kalman Filter
    property double raw_angle: sensorData.rawAngle
    property double filtered_angle: sensorData.filteredAngle


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
            dataValues: [x_axis, y_axis, z_axis]
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
            dataValues: [roll, pitch, yaw];
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
