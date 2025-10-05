import QtQuick
import QtQuick.Controls
import QtQuick.Window

Item {

    property Window targetWindow
    // property bool ctrl

    // Shortcut {
    //     sequence: "Control"


    // }

    Shortcut {
        sequence: "Ctrl+Q"
        onActivated: Qt.quit()
    }

    Shortcut {
        sequence: "F11"
        onActivated: {
            if(!targetWindow) return
            targetWindow.visibility =
                targetWindow.visibility === Window.FullScreen
                ? Window.Windowed
                : Window.FullScreen
        }
    }
}
