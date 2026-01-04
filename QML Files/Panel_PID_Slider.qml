import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts
import "Items"

BasePanel {
    id: pidPanel

    // Emits whenever the user saves new gains in the editor.
    signal pidGainsUpdated(string mode, double pGain, double iGain, double dGain)

    property int displayPrecision: 2
    property var editBuffer: []

    // Local store of PID gains for each mode.
    ListModel {
        id: pidModel
        ListElement { mode: "Hover"; pGain: 1.0; iGain: 2.2; dGain: 3.33 }
        ListElement { mode: "Up";    pGain: 2.0; iGain: 0.0; dGain: 0.0  }
        ListElement { mode: "Down";  pGain: 1.5; iGain: 1.0; dGain: 2.0  }
    }

    function modeColor(name) {
        if (name === "Hover") return "#60A5FA"
        if (name === "Up")    return "#34D399"
        if (name === "Down")  return "#FBBF24"
        return "#93C5FD"
    }

    function formatGain(value) {
        return Number(value).toFixed(displayPrecision)
    }

    function sanitizedNumber(value, fallback) {
        const parsed = Number(value)
        return isNaN(parsed) ? fallback : parsed
    }

    function syncEditBuffer() {
        const buffer = []
        for (let idx = 0; idx < pidModel.count; ++idx) {
            const row = pidModel.get(idx)
            buffer.push({
                mode: row.mode,
                pGain: row.pGain,
                iGain: row.iGain,
                dGain: row.dGain
            })
        }
        editBuffer = buffer
    }

    function applyEdits() {
        for (let idx = 0; idx < editBuffer.length; ++idx) {
            const current = pidModel.get(idx)
            const updated = editBuffer[idx] || {}

            const pVal = sanitizedNumber(updated.pGain, current.pGain)
            const iVal = sanitizedNumber(updated.iGain, current.iGain)
            const dVal = sanitizedNumber(updated.dGain, current.dGain)

            pidModel.setProperty(idx, "pGain", pVal)
            pidModel.setProperty(idx, "iGain", iVal)
            pidModel.setProperty(idx, "dGain", dVal)

            pidPanel.pidGainsUpdated(current.mode, pVal, iVal, dVal)
        }
        editorPopup.close()
    }

    BaseHeader {
        id: header
        headerText: "PID Controller"
    }

    Basic.Button {
        id: editButton
        text: "Edit PID Values"
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 12
        padding: 10
        font.pixelSize: 14
        hoverEnabled: true
        background: Rectangle {
            radius: 10
            color: editButton.down    ? "#1f3a6d"
                 : editButton.hovered ? "#1b335f"
                 :                      "#152844"
            border.width: 1
            border.color: "#2c4a7a"
        }
        contentItem: Text {
            anchors.centerIn: parent
            text: editButton.text
            color: "#c8ddff"
            font: editButton.font
        }
        onClicked: {
            syncEditBuffer()
            editorPopup.open()
        }
    }

    ColumnLayout {
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            topMargin: 12
            leftMargin: 12
            rightMargin: 12
            bottomMargin: 12
        }
        spacing: 10


        // PID rows
        Repeater {
            model: pidModel
            delegate: Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 72
                radius: 10
                color: "#0D131C"
                border.width: 1
                border.color: "#141C27"

                property color accent: modeColor(mode)

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    Rectangle {
                        width: 6
                        radius: 3
                        color: accent
                        Layout.fillHeight: true
                    }

                    Column {
                        Layout.preferredWidth: 90
                        spacing: 2

                        Text {
                            text: mode
                            color: "#DCE7F5"
                            font.pixelSize: 16
                            font.bold: true
                        }

                        Text {
                            text: "Flight Mode"
                            color: "#7B8798"
                            font.pixelSize: 12
                        }
                    }

                    // Gain chips
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Rectangle {
                            Layout.fillWidth: true
                            radius: 8
                            color: "#111827"
                            border.width: 1
                            border.color: "#1f2a3b"

                            Column {
                                anchors.centerIn: parent
                                spacing: 2
                                Text { text: "P"; color: "#9AA7B7"; font.pixelSize: 12; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                                Text { text: formatGain(pGain); color: "#E5E7EB"; font.pixelSize: 16; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            radius: 8
                            color: "#111827"
                            border.width: 1
                            border.color: "#1f2a3b"

                            Column {
                                anchors.centerIn: parent
                                spacing: 2
                                Text { text: "I"; color: "#9AA7B7"; font.pixelSize: 12; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                                Text { text: formatGain(iGain); color: "#E5E7EB"; font.pixelSize: 16; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            radius: 8
                            color: "#111827"
                            border.width: 1
                            border.color: "#1f2a3b"

                            Column {
                                anchors.centerIn: parent
                                spacing: 2
                                Text { text: "D"; color: "#9AA7B7"; font.pixelSize: 12; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                                Text { text: formatGain(dGain); color: "#E5E7EB"; font.pixelSize: 16; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                            }
                        }
                    }
                }
            }
        }
    }

    Popup {
        id: editorPopup
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape
        anchors.centerIn: Overlay.overlay
        width: 640
        padding: 0

        background: Rectangle {
            color: "#0D131C"
            radius: 12
            border.width: 1
            border.color: "#1f2a3b"
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            ColumnLayout {
                spacing: 4
                Layout.fillWidth: true
                Text { text: "Edit PID Values"; color: '#ffffff'; font.pixelSize: 20; font.bold: true }
            }

            Repeater {
                model: editBuffer
                delegate: ColumnLayout {
                    required property var modelData
                    required property int index
                    spacing: 6
                    Layout.fillWidth: true

                    Text {
                        text: modelData.mode
                        color: modeColor(modelData.mode)
                        font.pixelSize: 16
                        font.bold: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Basic.TextField {
                            Layout.preferredWidth: (editorPopup.width - 60) / 3
                            Layout.maximumWidth: Layout.preferredWidth
                            text: modelData.pGain
                            placeholderText: "P"
                            color: '#ffffff'
                            font.pixelSize: 14
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            validator: DoubleValidator { decimals: 4 }
                            background: Rectangle {
                                radius: 8
                                color: "#111827"
                                border.width: 1
                                border.color: "#1f2a3b"
                            }
                            onTextChanged: editBuffer[index].pGain = text
                        }

                        Basic.TextField {
                            Layout.preferredWidth: (editorPopup.width - 60) / 3
                            Layout.maximumWidth: Layout.preferredWidth
                            text: modelData.iGain
                            placeholderText: "I"
                            color: '#ffffff'
                            font.pixelSize: 14
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            validator: DoubleValidator { decimals: 4 }
                            background: Rectangle {
                                radius: 8
                                color: "#111827"
                                border.width: 1
                                border.color: "#1f2a3b"
                            }
                            onTextChanged: editBuffer[index].iGain = text
                        }

                        Basic.TextField {
                            Layout.preferredWidth: (editorPopup.width - 60) / 3
                            Layout.maximumWidth: Layout.preferredWidth
                            text: modelData.dGain
                            placeholderText: "D"
                            color: '#ffffff'
                            font.pixelSize: 14
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            validator: DoubleValidator { decimals: 4 }
                            background: Rectangle {
                                radius: 8
                                color: "#111827"
                                border.width: 1
                                border.color: "#1f2a3b"
                            }
                            onTextChanged: editBuffer[index].dGain = text
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Item { Layout.fillWidth: true }

                Basic.Button {
                    id: cancelButton
                    text: "Cancel"
                    padding: 10
                    font.pixelSize: 14
                    background: Rectangle {
                        radius: 10
                        color: "#1a2332"
                        border.width: 1
                        border.color: "#273246"
                    }
                    contentItem: Text {
                        anchors.centerIn: parent
                        text: cancelButton.text
                        color: "#c8d5e7"
                        font: cancelButton.font
                    }
                    onClicked: editorPopup.close()
                }

                Basic.Button {
                    id: saveButton
                    text: "Save Changes"
                    padding: 10
                    font.pixelSize: 14
                    background: Rectangle {
                        radius: 10
                        color: saveButton.down    ? "#1f3a6d"
                             : saveButton.hovered ? "#1b335f"
                             :                      "#152844"
                        border.width: 1
                        border.color: "#2c4a7a"
                    }
                    contentItem: Text {
                        anchors.centerIn: parent
                        text: saveButton.text
                        color: "#c8ddff"
                        font: saveButton.font
                    }
                    onClicked: applyEdits()
                }
            }
        }
    }
}