import QtQuick
import QtQuick.Layouts

// Rectangle {

// }

Rectangle {
    id: horDragRec

    property GridLayout grid
    property Item panel

    color: "transparent"
    anchors.fill: panel

    MouseArea {
        id: horDragRecMouseArea

        width: 4
        height: panel.height
        anchors {
            top: parent.top
            right: parent.right
        }
        cursorShape: Qt.SizeHorCursor

        property real startBlock
        property real currentBlock

        onClicked: (mouse) => {
            currentBlock = (panel.width + mouse.x) * (grid.columns/grid.width)
            startBlock = currentBlock
        }

        onPositionChanged: (mouse) => {
            currentBlock = (panel.width + mouse.x) * (grid.columns/grid.width)
            panel.Layout.columnSpan = currentBlock
            startBlock = currentBlock
        }
    }

    MouseArea {
        id: verDragRecMouseArea

        width: parent.width
        height: 4
        anchors {
            bottom: parent.bottom
            left: parent.left
        }
        cursorShape: Qt.SizeVerCursor

        property real startBlock
        property real currentBlock

        onClicked: (mouse) => {
            currentBlock = (panel.height + mouse.y) * (grid.rows/grid.height)
            startBlock = currentBlock
        }

        onPositionChanged: (mouse) => {
            currentBlock = (panel.height + mouse.y) * (grid.rows/grid.height)
            panel.Layout.rowSpan = currentBlock
            startBlock = currentBlock
        }
    }
}
