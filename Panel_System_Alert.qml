import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic   // skinnable controls
import "Items"

Rectangle {
    id: panel_System_Alert
    color: "#1F2937"
    border.color: "#2d3748"
    border.width: 4
    radius: 8
    height: (parent.parent.height - 20)/2
    width:  (parent.parent.width  - 20)/2  - 5

    // ---------- Header (left aligned) ----------
    BaseHeader {
        id: header
        headerText: "System Alert"
        defaultSize: 2

        Basic.Button {
            id: clearBtn

            anchors {
                top: parent.top
                right: parent.right
                rightMargin: 30
            }
            text: "CLEAR"
            hoverEnabled: true
            padding: 8
            font.pixelSize: parent.width/150 + panel_System_Alert.height/50 + 3
            background: Rectangle {
                radius: 8
                color: clearBtn.down    ? "#20375f"
                     : clearBtn.hovered ? "#1d3156"
                     :                    "#1a2c4d"
                border.width: 1
                border.color: "#2a3f63"
            }
            contentItem: Text {
                anchors.centerIn: parent
                text: clearBtn.text
                color: "#a8c4ea"
                font: clearBtn.font
            }
            onClicked: alertModel.clear()
        }
    }

    // ---------- Inner rounded container ----------
    Rectangle {
        id: inner
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: 10; rightMargin: 10; topMargin: 6; bottomMargin: 10
        }
        radius: 12
        color: "#0D131C"
        border.width: 1
        border.color: "#141C27"

        // --------- Model & View (only classified messages) ----------
        ListModel { id: alertModel }  // { ts: Date, level: "error|warning|success", text: string }

        ListView {
            id: list
            anchors.fill: parent
            anchors.margins: 10
            clip: true
            spacing: 10
            model: alertModel
            boundsBehavior: Flickable.StopAtBounds

            ScrollBar.vertical: Basic.ScrollBar {
                id: scrollBar
                policy: ScrollBar.AsNeeded
                contentItem: Rectangle {
                    implicitWidth: 6
                    radius: width/2
                    color: scrollBar.pressed ? "#536173"
                         : scrollBar.hovered ? "#455264"
                         :                    "#394454"
                }
                background: Rectangle { color: "transparent" }
            }

            function trim() { const max = 400; if (alertModel.count > max) alertModel.remove(0, alertModel.count - max); }
            Component.onCompleted: positionViewAtEnd()

            // ===== Delegate (uses exact red/yellow you specified) =====
            delegate: Rectangle {
                id: card
                width: ListView.view.width
                radius: 10
                color: "#101824"
                border.width: 1
                border.color: "#1A2330"
                antialiasing: true

                // ---- colors only; keep everything else exactly the same ----
                property color stripe:   (level==="error")   ? "#b63b3b"   // left bar
                                       : (level==="warning") ? "#cda53a"
                                       :                        "#1e8e61"
                property color chipBg:   (level==="error")   ? "#5a262a"   // pill background
                                       : (level==="warning") ? "#4b3d17"
                                       :                        "#123a2e"
                property color chipText: (level==="error")   ? "#f5c8c8"   // pill text
                                       : (level==="warning") ? "#ffe39a"
                                       :                        "#bfeeda"
                property color timeText: "#97a8bd"                         // timestamp
                property color bodyText: "#d5dde8"                         // main text

                property int padX: 12
                property int padY: 9
                height: Math.max(56, body.implicitHeight + padY*2)

                // left stripe (exact color)
                Rectangle {
                    anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom
                    width: 8; radius: 4; color: card.stripe
                }

                // content
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: padX + 8
                    anchors.rightMargin: padX
                    anchors.topMargin: padY
                    anchors.bottomMargin: padY
                    spacing: 10

                    // timestamp + chip stacked
                    Column {
                        Layout.alignment: Qt.AlignTop
                        Layout.preferredWidth: 78
                        spacing: 6

                        Text {
                            text: Qt.formatTime(ts, "hh:mm:ss")
                            color: card.timeText
                            font.pixelSize: 12
                            horizontalAlignment: Text.AlignLeft
                        }

                        Rectangle {
                            radius: 9; height: 20; width: implicitWidth
                            color: card.chipBg
                            border.width: 1
                            border.color: card.chipBg
                            property string label: (level==="error")? "ERROR" : (level==="warning")? "WARN" : "OK"
                            Text {
                                anchors.centerIn: parent
                                text: parent.label
                                color: card.chipText
                                font.pixelSize: 11; font.bold: true
                                padding: 9
                            }
                            implicitWidth: Math.max(54, childrenRect.width + 10)
                        }
                    }

                    // message body
                    Text {
                        id: body
                        Layout.fillWidth: true
                        text: model.text
                        color: card.bodyText
                        font.pixelSize: 15
                        wrapMode: Text.Wrap
                    }
                }
            }
        }
    }

    // ===== Helper to append & autoscroll =====
    function appendLine(level, line) {
        alertModel.append({ ts: new Date(), level: level, text: line })
        list.trim()
        list.positionViewAtEnd()
    }

    // ===== Listen to classified signals =====
    Connections {
        target: alarmreceiver
        function onRxError(line)   { appendLine("error",   line) }
        function onRxWarning(line) { appendLine("warning", line) }
        function onRxSuccess(line) { appendLine("success", line) }
    }
}
