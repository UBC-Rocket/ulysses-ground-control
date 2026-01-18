import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls.Basic as Basic

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
        color: "#111827"
        anchors {
            top: headerMain.bottom
            horizontalCenter: parent.horizontalCenter
        }


        // Initialize the layout
        LayoutGrid {

        }
    }

    property var settingsPage: null

    Component {
        id: settingsPageComponent
        SettingsPage { }
    }

    function openSettingsPage() {
        if (!settingsPage) {
            settingsPage = settingsPageComponent.createObject(window, {
                x: window.x + 60,
                y: window.y + 60
            })
        }
        settingsPage.show()
        settingsPage.raise()
        settingsPage.requestActivate()
    }

    // Top-right button to open the radio window
    Basic.Button {
        id: openSettingsBtn
        text: "Settings"
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 12
        padding: 10
        font.pixelSize: 14
        hoverEnabled: true
        background: Rectangle {
            radius: 10
            color: openSettingsBtn.down    ? "#1f3a6d"
                 : openSettingsBtn.hovered ? "#1b335f"
                 :                      "#152844"
            border.width: 1
            border.color: "#2c4a7a"
        }
        contentItem: Text {
            anchors.centerIn: parent
            text: openSettingsBtn.text
            color: "#c8ddff"
            font: openSettingsBtn.font
        }
        onClicked: openSettingsPage()
    }

}
