import QtQuick
import QtQuick.Layouts

GridLayout {
    //Initialize the layout
    id: grid
    flow: GridLayout.TopToBottom
    columns: 4
    rows: 2
    anchors.top: parent.top
    rowSpacing: 5
    columnSpacing: 5

    //Panels Margin
    property int margin: 2


    Panel_IMU_Data {
        Layout.margins: margin
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumWidth: width
        Layout.minimumHeight: height

        x_axis: 10      //Passing in arguments
        y_axis: 11
        z_axis: 12
        roll: 20
        pitch: 30
        yaw: 40
    }

    Panel_Control {
        Layout.margins: margin
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumWidth: width
        Layout.minimumHeight: height

    }

    Panel_Rocket_Visualization {
        Layout.margins: margin
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumWidth: width
        Layout.minimumHeight: height

        Layout.columnSpan: 2

        width: ((parent.parent.width - 20)/4 - 5)*(2)
    }

    Panel_Baro_Data {
        Layout.margins: margin
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumWidth: width
        Layout.minimumHeight: height
    }

    Panel_Engine_Control {
        Layout.margins: margin
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumWidth: width
        Layout.minimumHeight: height
    }

    Panel_Telemetry_Data {
        Layout.margins: margin
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumWidth: width
        Layout.minimumHeight: height
    }

    Panel_System_Alert {
        Layout.margins: margin
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumWidth: width
        Layout.minimumHeight: height
    }

    // Panel_Test {
    //     Layout.margins: margin
    //     Layout.fillWidth: true
    //     Layout.fillHeight: true
    //     Layout.minimumWidth: width
    //     Layout.minimumHeight: height

    //     width: ((parent.parent.width - 20)/4 - 5)

    // }


}
