import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

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

    property var radioConsole: null

        Component {
            id: radioConsoleComponent
            RadioTestWindow { }    // file: DualRadioWindow.qml
        }

        function openRadioConsole() {
            if (!radioConsole) {
                radioConsole = radioConsoleComponent.createObject(window, {
                    x: window.x + 60,
                    y: window.y + 60
                })
            }
            radioConsole.show()
            radioConsole.raise()
            radioConsole.requestActivate()
        }

        // Top-right button to open the radio window
        Button {
            id: openRadioBtn
            text: "Open Radio Console"
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 8
            z: 9999
            onClicked: openRadioConsole()
        }

}
