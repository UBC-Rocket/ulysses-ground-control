// DualRadioWindow.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

ApplicationWindow {
    id: radioWin
    width: 1100
    height: 700
    visible: false                        // opened from main window

    title: "Dual RFD900x Chat —  TX: "
           + (bridge.txPortName || "—") + "@" + (bridge.txBaud || "—")
           + "  |  RX: " + (bridge.rxPortName || "—") + "@" + (bridge.rxBaud || "—")
    modality: Qt.NonModal                 // non-blocking tool window
    flags: Qt.Window                      // normal top-level window
    property var baudList: [57600]        // keep in sync with your radios

    // Error popup bound to backend errorMessage
    Popup {
        id: errorPopup
        x: 16; y: 16
        modal: false; focus: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside   // quick dismiss
        contentItem: Frame { padding: 10; Label { id: errorLabel; wrapMode: Text.Wrap; text: "" } }
    }

    // Backend signal hookups (note the required "on" prefix)
    Connections {
        target: bridge
        function onErrorMessage(msg) { errorLabel.text = msg; errorPopup.open() }   // show friendly error
        function onRxTextReceived(line) { rxText.append(line + "\n") }              // append RX lines
        function onTxPortNameChanged() { radioWin.title = radioWin.title }          // force title recompute
        function onRxPortNameChanged() { radioWin.title = radioWin.title }
        function onTxBaudChanged()     { radioWin.title = radioWin.title }
        function onRxBaudChanged()     { radioWin.title = radioWin.title }
        function onTxConnectedChanged(){ radioWin.title = radioWin.title }
        function onRxConnectedChanged(){ radioWin.title = radioWin.title }
        function onButTxNotRadioModem(portName) { if (bridge.txConnected) txPane.txWarn = true } // light TX bar on probe fail
        function onButRxNotRadioModem(portName) { if (bridge.rxConnected) rxWarn = true }        // RX flag if you add a bar later
    }

    Connections {
        target: commandsender
    }

    // Top bar
    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            Label { text: "Dual RFD900x Chat"; font.bold: true; Layout.alignment: Qt.AlignVCenter; padding: 8 } // simple title
            Item { Layout.fillWidth: true }                                                                      // push right
            Button { text: "Refresh Ports"; onClicked: bridge.refreshPorts() }                                   // backend rescan
        }
    }

    // Two-column layout
    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        // ============================ TX COLUMN ============================
        Frame {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                id: txPane
                property bool txWarn: false                    // drives 1-line warning bar
                anchors.fill: parent
                spacing: 8

                Label { text: "Sender (TX)"; font.bold: true; padding: 4 } // section title

                RowLayout {
                    spacing: 8

                    ComboBox {
                        id: txPortSel
                        model: bridge.ports                     // **kept original model**
                        Layout.preferredWidth: 160
                        Component.onCompleted: {                // preselect current TX if present
                            const i = model.indexOf(bridge.txPortName); if (i >= 0) currentIndex = i;
                        }
                        onModelChanged: {                       // keep selection stable across refreshes
                            const i = model.indexOf(bridge.txPortName);
                            if (i >= 0) currentIndex = i;
                            else if (model.length > 0) currentIndex = 0;
                            else currentIndex = -1;
                        }
                    }

                    Button { text: "Refresh"; onClicked: bridge.refreshPorts() } // ask C++ to rebuild list

                    ComboBox {
                        id: txBaudSel
                        model: baudList
                        Layout.preferredWidth: 110
                        Component.onCompleted: {                // default to current (or 57600)
                            const i = baudList.indexOf(bridge.txBaud || 57600); if (i >= 0) currentIndex = i;
                        }
                    }

                    Button {
                        text: bridge.txConnected ? "Disconnect" : "Connect"
                        onClicked: {
                            if (bridge.txConnected) {
                                bridge.disconnectTxPort();      // release COM handle
                                txPane.txWarn = false;          // clear warning on disconnect
                            } else {
                                txPane.txWarn = false;          // clear stale warning before probing
                                bridge.connectTxPort(txPortSel.currentText, Number(txBaudSel.currentText));
                            }
                        }
                    }

                    Label {
                        text: bridge.txConnected ? "Connected" : "—"
                        color: bridge.txConnected ? "green" : "gray"
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

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
                            enabled: bridge.txConnected                   // disable until TX connected
                            onAccepted: { sendBtn.clicked() }             // Enter triggers send
                        }

                        RowLayout {
                            spacing: 10
                            Button {
                                id: sendBtn
                                text: "Send"
                                enabled: bridge.txConnected               // guard against closed port
                                onClicked: {
                                    if (txInput.text.length) {
                                        bridge.sendText(txInput.text);    // C++ send
                                        txInput.text = "";
                                    }
                                }
                            }
                        }

                        Item { Layout.fillHeight: true }                  // balance columns visually
                    }
                }

                GroupBox {
                    title: "Continuously Transmitting signals"
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 8
                        Button {
                            text: "Start 50Hz";
                            onClicked: commandsender.startPeriodic("H", 50)
                        }
                        Button {
                            text: "Stop";
                            onClicked: commandsender.stopPeriodic()
                        }

                        Item { Layout.fillHeight: true }                  // balance columns visually
                    }
                }

                // One-line TX warning (only after “not a radio” signal)
                Rectangle {
                    id: txWarnBar
                    Layout.fillWidth: true
                    visible: txPane.txWarn                                // collapses to 0px when false
                    height: visible ? 28 : 0
                    color: "#332"
                    border.color: "#f66"
                    radius: 4
                    clip: true

                    Text {
                        anchors.fill: parent; anchors.margins: 8
                        text: "The TX port connected seems like not a radio modem."
                        color: "#f66"; elide: Text.ElideRight; verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }

        // ============================ RX COLUMN ============================
        Frame {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                id: rxPane
                property bool rxWarn: false
                anchors.fill: parent
                spacing: 8

                Label { text: "Receiver (RX)"; font.bold: true; padding: 4 } // section title

                RowLayout {
                    spacing: 8

                    ComboBox {
                        id: rxPortSel
                        model: bridge.ports                                 // **kept original model**
                        Layout.preferredWidth: 160
                        Component.onCompleted: {                            // preselect current RX if present
                            const i = model.indexOf(bridge.rxPortName); if (i >= 0) currentIndex = i;
                        }
                        onModelChanged: {                                   // keep selection stable across refreshes
                            const i = model.indexOf(bridge.rxPortName);
                            if (i >= 0) currentIndex = i;
                            else if (model.length > 0) currentIndex = 0;
                            else currentIndex = -1;
                        }
                    }

                    Button { text: "Refresh"; onClicked: bridge.refreshPorts() } // rescan ports via backend

                    ComboBox {
                        id: rxBaudSel
                        model: baudList
                        Layout.preferredWidth: 110
                        Component.onCompleted: {
                            const i = baudList.indexOf(bridge.rxBaud || 57600); if (i >= 0) currentIndex = i;
                        }
                    }

                    Button {
                        text: bridge.rxConnected ? "Disconnect" : "Connect"
                        onClicked: {
                            if (bridge.rxConnected) {
                                bridge.disconnectRxPort();
                            } else {
                                bridge.connectRxPort(rxPortSel.currentText, Number(rxBaudSel.currentText));
                            }
                        }
                    }

                    Label {
                        text: bridge.rxConnected ? "Connected" : "—"
                        color: bridge.rxConnected ? "green" : "gray"
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

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
                            Item { Layout.fillWidth: true }                  // push clear right
                            Button { text: "Clear RX"; onClicked: rxText.text = "" }
                        }
                    }
                }

                // One-line TX warning (only after “not a radio” signal)
                Rectangle {
                    id: rxWarnBar
                    Layout.fillWidth: true
                    visible: rxPane.rxWarn                                // collapses to 0px when false
                    height: visible ? 28 : 0
                    color: "#332"
                    border.color: "#f66"
                    radius: 4
                    clip: true

                    Text {
                        anchors.fill: parent; anchors.margins: 8
                        text: "The RX port connected seems like not a radio modem."
                        color: "#f66"; elide: Text.ElideRight; verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }
}



