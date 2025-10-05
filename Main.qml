import QtQuick
import QtQuick.Controls
import QtQuick.Layouts


ApplicationWindow {
    //Initializing the Window
    id: window
    width: 1400
    height: 900
    visible: true
    title: qsTr("Ulysses Ground Control")
    color: "#111827"

    //Import all the keyboard shortcuts
    Shortcuts {
        targetWindow: window        //Passing in arguments
    }

    Header {
        id: headerMain
    }

    Rectangle {
        //Initialize the actual content board
        id: contentBoard
        width: parent.width - 4
        height: parent.height - (headerMain.height) - 4
        y: headerMain.height
        anchors.horizontalCenter: parent.horizontalCenter
        color: "#111827"

        // Initialize the layout
        LayoutGrid {

        }

    }
}
