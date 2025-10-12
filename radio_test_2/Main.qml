// main.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: win
    width: 1100
    height: 700
    visible: true
    title: `Dual RFD900x Chat —  TX: ${bridge.txPortName || "—"}@${bridge.txBaud || "—"}  |  RX: ${bridge.rxPortName || "—"}@${bridge.rxBaud || "—"}`

    // Common baud list
    property var baudList: [9600, 57600, 115200]

    // Local state for TX input
    property bool enterToSend: true

    // Error banner
    Popup {
        id: errorPopup
        x: 16; y: 16
        modal: false; focus: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        contentItem: Frame {
            padding: 10
            Label { id: errorLabel; wrapMode: Text.Wrap; text: "" }
        }
    }

    // Backend signal hookups
    Connections {
        target: bridge
        function onErrorMessage(msg) {
            errorLabel.text = msg
            errorPopup.open()
        }
        function onRxTextRecieved(line) {
            rxText.append(line + "\n")
        }
        // Keep window title live when these change
        function onTxPortNameChanged() { win.title = win.title } // forces recompute of template literal
        function onRxPortNameChanged() { win.title = win.title }
        function onTxBaudChanged()     { win.title = win.title }
        function onRxBaudChanged()     { win.title = win.title }
        function onTxConnectedChanged(){ win.title = win.title }
        function onRxConnectedChanged(){ win.title = win.title }
    }

    // Top bar: nothing fancy; could add global refresh if you like
    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            Label {
                text: "Dual RFD900x Chat"
                font.bold: true
                Layout.alignment: Qt.AlignVCenter
                padding: 8
            }
            Item { Layout.fillWidth: true }
            Button {
                text: "Refresh Ports"
                onClicked: bridge.refreshPorts()
            }
        }
    }

    // Main body: two equal columns
    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        // -------------------------- TX Column --------------------------
        Frame {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 8

                // Title
                Label {
                    text: "Sender (TX)"
                    font.bold: true
                    padding: 4
                }

                // Port + Refresh + Baud + Connect/Disconnect
                RowLayout {
                    spacing: 8

                    ComboBox {
                        id: txPortSel
                        model: bridge.ports
                        Layout.preferredWidth: 160
                        editable: false
                        // Try to select current name if already connected
                        Component.onCompleted: {
                            const idx = bridge.ports.indexOf(bridge.txPortName)
                            if (idx >= 0) txPortSel.currentIndex = idx
                        }
                    }

                    Button {
                        text: "Refresh"
                        onClicked: bridge.refreshPorts()
                    }

                    ComboBox {
                        id: txBaudSel
                        model: baudList
                        Layout.preferredWidth: 110
                        Component.onCompleted: {
                            const idx = baudList.indexOf(bridge.txBaud || 9600)
                            if (idx >= 0) txBaudSel.currentIndex = idx
                        }
                    }

                    Button {
                        text: bridge.txConnected ? "Disconnect" : "Connect"
                        onClicked: {
                            if (bridge.txConnected) bridge.disconnectTxPort()
                            else bridge.connectTxPort(txPortSel.currentText, Number(txBaudSel.currentText))
                        }
                    }

                    Label {
                        text: bridge.txConnected ? "Connected" : "—"
                        color: bridge.txConnected ? "green" : "gray"
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                // Type & Send via TX
                GroupBox {
                    title: "Type & Send via TX"
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 8

                        TextField {
                            id: txInput
                            placeholderText: "Type text to send…"
                            Layout.fillWidth: true
                            onAccepted: {
                                if (enterChk.checked) sendBtn.clicked()
                            }
                            enabled: bridge.txConnected
                        }

                        RowLayout {
                            spacing: 10
                            Button {
                                id: sendBtn
                                text: "Send"
                                enabled: bridge.txConnected
                                onClicked: {
                                    if (txInput.text.length === 0) return
                                    bridge.sendText(txInput.text)
                                    txInput.text = ""
                                }
                            }
                            CheckBox {
                                id: enterChk
                                text: "Enter to send"
                                checked: true
                            }
                            Label {
                                text: `TX → ${bridge.txPortName || "—"}@${bridge.txBaud || "—"}`
                                color: "gray"
                            }
                        }

                        // Spacer to make TX/RX columns the same height
                        Item { Layout.fillHeight: true }
                    }
                }
            }
        }

        // -------------------------- RX Column --------------------------
        Frame {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 8

                // Title
                Label {
                    text: "Receiver (RX)"
                    font.bold: true
                    padding: 4
                }

                // Port + Refresh + Baud + Connect/Disconnect
                RowLayout {
                    spacing: 8

                    ComboBox {
                        id: rxPortSel
                        model: bridge.ports
                        Layout.preferredWidth: 160
                        editable: false
                        Component.onCompleted: {
                            const idx = bridge.ports.indexOf(bridge.rxPortName)
                            if (idx >= 0) rxPortSel.currentIndex = idx
                        }
                    }

                    Button {
                        text: "Refresh"
                        onClicked: bridge.refreshPorts()
                    }

                    ComboBox {
                        id: rxBaudSel
                        model: baudList
                        Layout.preferredWidth: 110
                        Component.onCompleted: {
                            const idx = baudList.indexOf(bridge.rxBaud || 9600)
                            if (idx >= 0) rxBaudSel.currentIndex = idx
                        }
                    }

                    Button {
                        text: bridge.rxConnected ? "Disconnect" : "Connect"
                        onClicked: {
                            if (bridge.rxConnected) bridge.disconnectRxPort()
                            else bridge.connectRxPort(rxPortSel.currentText, Number(rxBaudSel.currentText))
                        }
                    }

                    Label {
                        text: bridge.rxConnected ? "Connected" : "—"
                        color: bridge.rxConnected ? "green" : "gray"
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                // RX text area
                GroupBox {
                    title: "Received from RX"
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 8

                        TextArea {
                            id: rxText
                            readOnly: true
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            font.family: "Consolas"
                        }

                        RowLayout {
                            Item { Layout.fillWidth: true }
                            Button {
                                text: "Clear RX"
                                onClicked: rxText.text = ""
                            }
                        }
                    }
                }
            }
        }
    }
}

