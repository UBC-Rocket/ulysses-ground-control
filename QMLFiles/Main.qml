import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts
import QtQuick.Window
import "Items"

ApplicationWindow {
    //Initializing the Window
    id: window
    width: 1400
    height: 900
    visible: true
    title: qsTr("Ulysses Ground Control")
    color: Theme.background

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
        color: Theme.background
        anchors {
            top: headerMain.bottom
            horizontalCenter: parent.horizontalCenter
        }


        // Initialize the layout
        LayoutGrid {
        }
    }

    property var radioConsole: null
    property var radioOutput: null

    Component {
        id: radioConsoleComponent
        RadioTestWindow { }
    }

    Component {
        id: radioOutputComponent
        RadioOutputWindow { }
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
    function openRadioOutput() {
        if (!radioOutput) {
            radioOutput = radioOutputComponent.createObject(window, {
                x: window.x + 40,
                y: window.y + 40
            })
        }
        radioOutput.show()
        radioOutput.raise()
        radioOutput.requestActivate()
    }

    // Bottom-right button to open the radio output window
    Basic.Button {
        id: openRadioOutputBtn
        text: "Radio Output"
        anchors.bottom: parent.bottom
        anchors.right: openRadioBtn.left
        anchors.margins: 8
        z: 9999
        hoverEnabled: true
        padding: 10
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontBody

        background: Rectangle {
            radius: Theme.radiusControl
            color: openRadioOutputBtn.down    ? Theme.btnPrimaryPress
                 : openRadioOutputBtn.hovered ? Theme.btnPrimaryHover
                 :                              Theme.btnPrimaryBg
            border.width: Theme.strokeControl
            border.color: Theme.btnPrimaryBorder
            Behavior on color { ColorAnimation { duration: Theme.transitionFast } }
        }
        contentItem: Text {
            text: openRadioOutputBtn.text
            color: Theme.btnPrimaryText
            font: openRadioOutputBtn.font
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        onClicked: openRadioOutput()
    }

    // Bottom-right button to open the radio console window
    Basic.Button {
        id: openRadioBtn
        text: "Open Radio Console"
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 8
        z: 9999
        hoverEnabled: true
        padding: 10
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontBody

        background: Rectangle {
            radius: Theme.radiusControl
            color: openRadioBtn.down    ? Theme.btnPrimaryPress
                 : openRadioBtn.hovered ? Theme.btnPrimaryHover
                 :                        Theme.btnPrimaryBg
            border.width: Theme.strokeControl
            border.color: Theme.btnPrimaryBorder
            Behavior on color { ColorAnimation { duration: Theme.transitionFast } }
        }
        contentItem: Text {
            text: openRadioBtn.text
            color: Theme.btnPrimaryText
            font: openRadioBtn.font
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        onClicked: openRadioConsole()
    }

}
