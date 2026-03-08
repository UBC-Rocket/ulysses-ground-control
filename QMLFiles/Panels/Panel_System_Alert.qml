import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic   // skinnable controls
import "Items"

BasePanel {
    id: panel

    // ---------- Header (left aligned) ----------
    RowLayout {
        id: headerRow
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 12
        }
        spacing: 8

        Text {
            id: header_System_Alert
            text: "System Alert"
            color: Theme.accent
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontH1
            font.bold: true
        }

        Item { Layout.fillWidth: true }

        // compact CLEAR button
        Basic.Button {
            id: clearBtn
            text: "CLEAR"
            hoverEnabled: true
            padding: 8
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody
            background: Rectangle {
                radius: Theme.radiusControl
                color: clearBtn.down    ? Theme.btnSecondaryPress
                     : clearBtn.hovered ? Theme.btnSecondaryHover
                     :                    Theme.btnSecondaryBg
                border.width: Theme.strokeControl
                border.color: Theme.btnSecondaryBorder
            }
            contentItem: Text {
                anchors.centerIn: parent
                text: clearBtn.text
                color: Theme.btnSecondaryText
                font: clearBtn.font
            }
            onClicked: alertModel.clear()
        }
    }

    // ---------- Inner rounded container ----------
    Rectangle {
        id: inner
        anchors {
            top: headerRow.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: 10; rightMargin: 10; topMargin: 6; bottomMargin: 10
        }
        radius: Theme.radiusCard
        color: Theme.surfaceInset
        border.width: Theme.strokeControl
        border.color: Theme.border

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
                id: control
                policy: ScrollBar.AsNeeded
                contentItem: Rectangle {
                    implicitWidth: 6
                    radius: width/2
                    color: parent.pressed ? Theme.textSecondary
                         : parent.hovered ? Theme.textTertiary
                         :                  Theme.borderLight
                }
                background: Rectangle { color: "transparent" }
            }

            function trim() { const max = 400; if (alertModel.count > max) alertModel.remove(0, alertModel.count - max); }
            Component.onCompleted: positionViewAtEnd()

            // ===== Delegate (uses exact red/yellow you specified) =====
            delegate: Rectangle {
                id: card
                width: ListView.view.width
                radius: Theme.radiusCard
                color: Theme.surfaceElevated
                border.width: Theme.strokeControl
                border.color: Theme.border
                antialiasing: true

                // ---- colors only; keep everything else exactly the same ----
                property color stripe:   (level==="error")   ? Theme.danger
                                       : (level==="warning") ? Theme.warn
                                       :                        Theme.success
                property color chipBg:   (level==="error")   ? Theme.dangerBg
                                       : (level==="warning") ? Theme.warnBg
                                       :                        Theme.successBg
                property color chipText: (level==="error")   ? Theme.dangerText
                                       : (level==="warning") ? Theme.warnText
                                       :                        Theme.successText
                property color timeText: Theme.textSecondary
                property color bodyText: Theme.textPrimary

                property int padX: 12
                property int padY: 9
                height: Math.max(56, body.implicitHeight + padY*2)

                // left stripe (exact color)
                Rectangle {
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }
                    width: 8;
                    radius: 4;
                    color: card.stripe
                }

                // content
                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: padX + 8;
                        rightMargin: padX
                        topMargin: padY
                        bottomMargin: padY
                    }
                    spacing: 10

                    // timestamp + chip stacked
                    Column {
                        Layout.alignment: Qt.AlignTop
                        Layout.preferredWidth: 78
                        spacing: 6

                        Text {
                            text: Qt.formatTime(ts, "hh:mm:ss")
                            color: card.timeText
                            font.family: Theme.monoFamily
                            font.pixelSize: 12
                            horizontalAlignment: Text.AlignLeft
                        }

                        Rectangle {
                            id: chip
                            radius: 9
                            height: 20
                            color: card.chipBg
                            border.width: 1
                            border.color: card.chipBg
                            property string label: (level === "error")   ? "ERROR"
                                                  : (level === "warning")? "WARN"
                                                  : "OK"

                            Text {
                                id: chipText
                                anchors.centerIn: parent
                                text: parent.label
                                color: card.chipText
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontCaption
                                font.bold: true
                                padding: 9
                            }

                            width: Math.max(54, chipText.implicitWidth + 2 * chipText.padding)
                        }

                    }

                    // message body
                    Text {
                        id: body
                        Layout.fillWidth: true
                        text: model.text
                        color: card.bodyText
                        font.family: Theme.fontFamily
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
