import QtQuick
import QtQuick.Layouts

Rectangle {
    id: dragRec

    property GridLayout grid
    property Item panel
    // property int minimumSize: 10
    property int minimumHeight: 10
    property int minimumWidth: 10

    color: "transparent"
    anchors.fill: panel

    MouseArea {
        id: horDragRecMouseAreaRight

        //Initialize the line to drag
        width: 4
        height: panel.height
        anchors {
            top: parent.top
            right: parent.right
        }
        cursorShape: Qt.SizeHorCursor

        //Record the starting state of the panel
        property int  startCol
        property int  startSpan
        property real startX

        onPressed: (mouse) => {
            startCol = panel.Layout.column
            startSpan = panel.Layout.columnSpan
            startX = mouse.x

            //Temporarily remove the panel to avoid collision to itself
            grid.clearT(panel)
        }

        property real units: grid.columns / grid.width
        property real dCols

        onPositionChanged: (mouse) => {
            // Determine the new span
            dCols = (mouse.x - startX) * units
            let proposedSpan = Math.ceil(startSpan + dCols)

            // Check of collision with other panels
            let ok = true
            for (let r = panel.Layout.row; ok && r < panel.Layout.row + panel.Layout.rowSpan; r++)
                for (let c = startCol + startSpan; ok && c < startCol + proposedSpan; c++)
                    ok = (grid.filled[r][c] === 0)

            // Set the new span
            if (ok) {
                panel.Layout.columnSpan = Math.max(proposedSpan, minimumWidth)
            }
        }

        // Update the new panel onto the grid
        onReleased: {
            grid.initT(panel)
        }
    }

    MouseArea {
        id: horDragRecMouseAreaLeft

        //Initialize the line to drag
        width: 4
        height: panel.height
        anchors {
            top: parent.top
            left: parent.left
        }
        cursorShape: Qt.SizeHorCursor

        //Record the starting state of the panel
        property int  startCol
        property int  startSpan
        property real startX
        property int  rightCol

        onPressed: (mouse) => {
            startCol = panel.Layout.column
            startSpan = panel.Layout.columnSpan
            startX = mouse.x
            rightCol = startCol + panel.Layout.columnSpan

            //Temporarily remove the panel to avoid collision to itself
            grid.clearT(panel)
        }

        property real units: grid.columns / grid.width
        property real dCols

        onPositionChanged: (mouse) => {
            // Determine the new column and span
            dCols = (mouse.x - startX) * units
            let proposedCol = Math.floor(startCol + dCols)
            let proposedSpan = Math.floor(rightCol - proposedCol)

            // Check of collision with other panels
            let ok = true
            for (let r = panel.Layout.row; ok && r < panel.Layout.row + panel.Layout.rowSpan; ++r)
                for (let c = proposedCol; ok && c < rightCol; ++c)
                    ok = (grid.filled[r][c] === 0)


            // Set the new column and span
            if (ok) {
                panel.Layout.column = Math.max(0, Math.min(proposedCol, rightCol - minimumWidth))
                panel.Layout.columnSpan = Math.max(minimumWidth, rightCol - proposedCol)
            }
        }

        // Update the new panel onto the grid
        onReleased: {
            grid.initT(panel)
        }
    }

    MouseArea {
        id: verDragRecMouseAreaBottom

        //Initialize the line to drag
        width: parent.width
        height: 4
        anchors {
            bottom: parent.bottom
            left: parent.left
        }
        cursorShape: Qt.SizeVerCursor

        //Record the starting state of the panel
        property int  startRow
        property int  startSpan
        property real startY

        onPressed: (mouse) => {
            startRow = panel.Layout.row
            startSpan = panel.Layout.rowSpan
            startY = mouse.y

            //Temporarily remove the panel to avoid collision to itself
            grid.clearT(panel)
        }

        property real units: grid.rows / grid.height
        property real dRows

        onPositionChanged: (mouse) => {
            // Determine the new span
            dRows = (mouse.y - startY) * units
            let proposedSpan = Math.ceil(startSpan + dRows)

            // Check of collision with other panels
            let ok = true
            for (let r = startRow + startSpan; ok && r < startRow + proposedSpan; r++)
                for (let c = panel.Layout.column; ok && c < panel.Layout.column + panel.Layout.columnSpan; c++)
                    ok = (grid.filled[r][c] === 0)

            // Set the new span
            if (ok) {
                panel.Layout.rowSpan = Math.max(proposedSpan, minimumHeight)
            }
        }

        // Update the new panel onto the grid
        onReleased: {
            grid.initT(panel)
        }
    }

    MouseArea {
        id: verDragRecMouseAreaTop

        //Initialize the line to drag
        width: panel.width
        height: 4
        anchors {
            top: parent.top
            left: parent.left
        }
        cursorShape: Qt.SizeVerCursor

        //Record the starting state of the panel
        property int  startRow
        property int  startSpan
        property real startY
        property int  bottomRow

        onPressed: (mouse) => {
            startRow = panel.Layout.row
            startSpan = panel.Layout.rowSpan
            startY = mouse.y
            bottomRow = startRow + panel.Layout.rowSpan

            //Temporarily remove the panel to avoid collision to itself
            grid.clearT(panel)
        }

        property real units: grid.rows / grid.height
        property real dRows

        onPositionChanged: (mouse) => {
            // Determine the new row and span
            dRows = (mouse.y - startY) * units
            let proposedRow = Math.floor(startRow + dRows)
            let proposedSpan = Math.floor(bottomRow - proposedRow)

            // Check of collision with other panels
            let ok = true
                for (let r = proposedRow; ok && r < bottomRow; ++r)
                    for (let c = panel.Layout.column; ok && c < panel.Layout.column + panel.Layout.columnSpan; ++c)
                        ok = (grid.filled[r][c] === 0)

            // Set the new row and span
            if (ok) {
                panel.Layout.row = Math.max(0, Math.min(proposedRow, bottomRow - minimumHeight))
                panel.Layout.rowSpan = Math.max(minimumHeight, bottomRow - proposedRow)
            }
        }

        // Update the new panel onto the grid
        onReleased: {
            grid.initT(panel)
        }
    }
}
