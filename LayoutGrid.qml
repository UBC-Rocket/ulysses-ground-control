import QtQuick
import QtQuick.Layouts

GridLayout {
    //Initialize the layout
    id: grid

    flow: GridLayout.TopToBottom
    columns: 4
    rows: 2
    rowSpacing: 5
    columnSpacing: 5
    anchors {
        fill: parent
        topMargin: 2
    }

    //The Panels
    Panel_IMU_And_Kalman_Data {
        //IMU Data
        x_axis: 10
        y_axis: 11
        z_axis: 12
        roll: 20
        pitch: 30
        yaw: 40

        //Kalman Data
        raw_angle: 10
        filtered_angle: 20
    }

    Panel_Test {
    }

    Panel_Rocket_Visualization {
        Layout.columnSpan: 2
    }

    Panel_Test {
    }

    Panel_Engine_Control {
    }

    Panel_Baro_And_Telemetry_Data {
    }

    Panel_System_Alert {
    }
}
