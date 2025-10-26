import QtQuick
import "Items"

BasePanel {
    id: panel_Engine

    //Parameters
    property double throttle
    property double fuel

    BaseHeader {
        id:header
        headerText: "Engine Control"
    }

    Rectangle {
        id: throttle_and_fuel

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: header.height
        anchors.leftMargin: header.anchors.leftMargin
        height: 200

        DataBoxList {
            anchors.top: throttle_and_fuel.top
            width: panel_Engine.width;

            size: 2
            boxHeight: 70
            dataNames: ["THROTTLE (%)", "FUEL (%)"]
            dataValues: [throttle, fuel]
        }
    }
}
