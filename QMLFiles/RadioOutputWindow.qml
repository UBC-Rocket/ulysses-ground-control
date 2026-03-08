import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import "Items"

ApplicationWindow {
    id: radioOutWin
    width: 820
    height: 700
    visible: false
    title: "Radio Output — Raw Packets"
    modality: Qt.NonModal
    flags: Qt.Window

    font.family: Theme.fontFamily

    palette {
        window:          Theme.background
        base:            Theme.surfaceInset
        alternateBase:   Theme.surfaceElevated
        text:            Theme.textPrimary
        windowText:      Theme.textPrimary
        button:          Theme.btnSecondaryBg
        buttonText:      Theme.btnSecondaryText
        highlight:       Theme.accent
        highlightedText: Theme.background
        placeholderText: Theme.textTertiary
        mid:             Theme.border
        dark:            Theme.border
        light:           Theme.borderLight
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.paddingMd
        spacing: Theme.paddingSm

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: width
            contentHeight: outputText.paintedHeight
            clip: true

            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            TextEdit {
                id: outputText
                width: parent.width
                readOnly: true
                selectByMouse: true
                wrapMode: TextEdit.WrapAnywhere
                font.family: Theme.monoFamily
                font.pixelSize: Theme.fontBody
                color: Theme.textPrimary
                text: sensorData.rawPacketLog

                onTextChanged: {
                    parent.contentY = Math.max(0, parent.contentHeight - parent.height)
                }
            }
        }

        Button {
            text: "Clear"
            Layout.alignment: Qt.AlignRight
            onClicked: sensorData.clearRawPacketLog()
        }
    }
}
