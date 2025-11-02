import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: base

    //Visualization
    color: "#1F2937"
    border.color: "#2d3748"
    border.width: 4
    radius: 8

    //Sizing
    height: (parent.parent.height - 20)/2 - 10
    width: (parent.parent.width - 20)/4 - 5

    //Layout
    Layout.margins: 2
    Layout.fillWidth: true
    Layout.fillHeight: true
    // Layout.minimumWidth: width
    // Layout.minimumHeight: height

    Rectangle {
        id: horDragRec

        width: 4
        height: base.height
        color: "yellow"
        anchors {
            top: parent.top
            right: parent.right
        }
        
        MouseArea {
            id: horDragRecMouseArea

            property real startX
            property real startWidth

            anchors.fill: parent
            cursorShape: Qt.SizeHorCursor
            drag {
                target: parent
                smoothed: true
                axis: Drag.XAxis
            }
            
            onPressed: {
                startX = mouse.x
                startWidth = base.width
            }

            onPositionChanged: {
                base.width = startWidth + (mouse.x - startX)
            }
        }
    }

    Rectangle {
        id: verDragRec

        width: base.width
        height: 4
        color: "yellow"
        anchors {
            bottom: parent.bottom
            left: parent.left
        }

        MouseArea {
            id: verDragRecMouseArea

            property real startY
            property real startHeight

            anchors.fill: parent
            cursorShape: Qt.SizeVerCursor
            drag {
                target: parent
                smoothed: true
                axis: Drag.YAxis
            }

            onPressed: {
                startY = mouse.y
                startHeight = base.height
            }

            onPositionChanged: {
                base.height = startHeight + (mouse.y - startY)
            }
        }

    }
}
