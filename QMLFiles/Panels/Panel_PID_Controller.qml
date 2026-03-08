import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts
import "../Items"

BasePanel {
    id: pidPanel

    signal commandTriggered(int which, var code)

    // Emits whenever the user saves new gains in the editor.
    signal pidGainsUpdated(string mode, double pGain, double iGain, double dGain)

    property int displayPrecision: 2
    property var editBuffer: []
    property var pidValues: []

    // TODO: check if channel 1 is valid for PID Value sending
    property int which: 1

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
        return Theme.accent
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

            pidValues[idx * 3] = pVal
            pidValues[idx * 3 + 1] = iVal
            pidValues[idx * 3 + 2] = dVal

            pidModel.setProperty(idx, "pGain", pVal)
            pidModel.setProperty(idx, "iGain", iVal)
            pidModel.setProperty(idx, "dGain", dVal)

            pidPanel.pidGainsUpdated(current.mode, pVal, iVal, dVal)
        }

        pidPanel.commandTriggered(which, pidValues);

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
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontBody
        hoverEnabled: true
        background: Rectangle {
            radius: Theme.radiusControl
            color: editButton.down    ? Theme.btnPrimaryPress
                 : editButton.hovered ? Theme.btnPrimaryHover
                 :                      Theme.btnPrimaryBg
            border.width: Theme.strokeControl
            border.color: Theme.btnPrimaryBorder
        }
        contentItem: Text {
            anchors.centerIn: parent
            text: editButton.text
            color: Theme.btnPrimaryText
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
                radius: Theme.radiusCard
                color: Theme.surfaceInset
                border.width: Theme.strokeControl
                border.color: Theme.border

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
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontH2
                            font.bold: true
                        }

                        Text {
                            text: "Flight Mode"
                            color: Theme.textTertiary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                        }
                    }

                    // Gain chips
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Rectangle {
                            Layout.fillWidth: true
                            radius: Theme.radiusCard
                            color: Theme.background
                            border.width: Theme.strokeControl
                            border.color: Theme.border

                            Column {
                                anchors.centerIn: parent
                                spacing: 2
                                Text { text: "P"; color: Theme.textTertiary; font.family: Theme.fontFamily; font.pixelSize: 12; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                                Text { text: formatGain(pGain); color: Theme.textPrimary; font.family: Theme.monoFamily; font.pixelSize: Theme.fontH2; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            radius: Theme.radiusCard
                            color: Theme.background
                            border.width: Theme.strokeControl
                            border.color: Theme.border

                            Column {
                                anchors.centerIn: parent
                                spacing: 2
                                Text { text: "I"; color: Theme.textTertiary; font.family: Theme.fontFamily; font.pixelSize: 12; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                                Text { text: formatGain(iGain); color: Theme.textPrimary; font.family: Theme.monoFamily; font.pixelSize: Theme.fontH2; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            radius: Theme.radiusCard
                            color: Theme.background
                            border.width: Theme.strokeControl
                            border.color: Theme.border

                            Column {
                                anchors.centerIn: parent
                                spacing: 2
                                Text { text: "D"; color: Theme.textTertiary; font.family: Theme.fontFamily; font.pixelSize: 12; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                                Text { text: formatGain(dGain); color: Theme.textPrimary; font.family: Theme.monoFamily; font.pixelSize: Theme.fontH2; font.bold: true; horizontalAlignment: Text.AlignHCenter }
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
            color: Theme.surfaceInset
            radius: 12
            border.width: Theme.strokeControl
            border.color: Theme.border
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            ColumnLayout {
                spacing: 4
                Layout.fillWidth: true
                Text { text: "Edit PID Values"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 20; font.bold: true }
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
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontH2
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
                            color: Theme.textPrimary
                            font.family: Theme.monoFamily
                            font.pixelSize: Theme.fontBody
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            validator: DoubleValidator { decimals: 4 }
                            background: Rectangle {
                                radius: Theme.radiusCard
                                color: Theme.background
                                border.width: Theme.strokeControl
                                border.color: Theme.border
                            }
                            onTextChanged: editBuffer[index].pGain = text
                        }

                        Basic.TextField {
                            Layout.preferredWidth: (editorPopup.width - 60) / 3
                            Layout.maximumWidth: Layout.preferredWidth
                            text: modelData.iGain
                            placeholderText: "I"
                            color: Theme.textPrimary
                            font.family: Theme.monoFamily
                            font.pixelSize: Theme.fontBody
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            validator: DoubleValidator { decimals: 4 }
                            background: Rectangle {
                                radius: Theme.radiusCard
                                color: Theme.background
                                border.width: Theme.strokeControl
                                border.color: Theme.border
                            }
                            onTextChanged: editBuffer[index].iGain = text
                        }

                        Basic.TextField {
                            Layout.preferredWidth: (editorPopup.width - 60) / 3
                            Layout.maximumWidth: Layout.preferredWidth
                            text: modelData.dGain
                            placeholderText: "D"
                            color: Theme.textPrimary
                            font.family: Theme.monoFamily
                            font.pixelSize: Theme.fontBody
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            validator: DoubleValidator { decimals: 4 }
                            background: Rectangle {
                                radius: Theme.radiusCard
                                color: Theme.background
                                border.width: Theme.strokeControl
                                border.color: Theme.border
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
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontBody
                    background: Rectangle {
                        radius: Theme.radiusControl
                        color: Theme.btnSecondaryBg
                        border.width: Theme.strokeControl
                        border.color: Theme.btnSecondaryBorder
                    }
                    contentItem: Text {
                        anchors.centerIn: parent
                        text: cancelButton.text
                        color: Theme.btnSecondaryText
                        font: cancelButton.font
                    }
                    onClicked: editorPopup.close()
                }

                Basic.Button {
                    id: saveButton
                    text: "Save Changes"
                    padding: 10
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontBody
                    background: Rectangle {
                        radius: Theme.radiusControl
                        color: saveButton.down    ? Theme.btnPrimaryPress
                             : saveButton.hovered ? Theme.btnPrimaryHover
                             :                      Theme.btnPrimaryBg
                        border.width: Theme.strokeControl
                        border.color: Theme.btnPrimaryBorder
                    }
                    contentItem: Text {
                        anchors.centerIn: parent
                        text: saveButton.text
                        color: Theme.btnPrimaryText
                        font: saveButton.font
                    }
                    onClicked: applyEdits()
                }
            }
        }
    }
    // --- Signal wiring: when a card is clicked, forward the code to the C++ CommandSender object ---
    Connections {
        target: pidPanel
        function onCommandTriggered(txWhich, code) {
            commandsender.sendPIDValues(txWhich, code) // Delegate to Q_INVOKABLE; panel stays transport-agnostic.
        }
    }
}
