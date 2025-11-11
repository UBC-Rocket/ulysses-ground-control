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

        height: (parent.height-header.height)/3
        anchors {
            top: header.bottom
            left: parent.left
            leftMargin: header.anchors.leftMargin
        }

        DataBoxList {
            anchors.top: throttle_and_fuel.top
            width: panel_Engine.width;

            size: 2
            dataNames: ["THROTTLE (%)", "FUEL (%)"]
            dataValues: [throttle, fuel]
        }
    }
}
