import QtQuick
import QtQuick.Controls
import QtQuick.Window

Item {

    property Window targetWindow

    Shortcut {
        sequence: "Delete"
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
