// DualRadioWindow.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

ApplicationWindow {
    id: radioWin
    width: 1100
    height: 700
    visible: false            // created hidden; main page will .show()
    title: "Dual RFD900x Chat —  TX: "
           + (bridge.txPortName || "—") + "@" + (bridge.txBaud || "—")  // title recomputes from bindings
           + "  |  RX: " + (bridge.rxPortName || "—") + "@" + (bridge.rxBaud || "—")
    modality: Qt.NonModal     // non-blocking window over main UI
    flags: Qt.Window          // standard top-level window flags

    // Common baud list + minor state
    property var baudList: [9600, 57600, 115200] // basic baud presets shown in ComboBoxes

    // Error banner
    Popup {
        id: errorPopup
        x: 16; y: 16
        modal: false; focus: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside // easy dismiss UX
        contentItem: Frame { padding: 10; Label { id: errorLabel; wrapMode: Text.Wrap; text: "" } } // message container
    }

    // Backend signals
    Connections {
        target: bridge
        function onErrorMessage(msg) { errorLabel.text = msg; errorPopup.open() } // show backend error in popup
        function onRxTextReceived(line) { rxText.append(line + "\n") }            // append each received line to TextArea
        function onTxPortNameChanged() { radioWin.title = radioWin.title }        // reassign to trigger title binding refresh
        function onRxPortNameChanged() { radioWin.title = radioWin.title }        // same pattern for other title parts
        function onTxBaudChanged()     { radioWin.title = radioWin.title }
        function onRxBaudChanged()     { radioWin.title = radioWin.title }
        function onTxConnectedChanged(){ radioWin.title = radioWin.title }
        function onRxConnectedChanged(){ radioWin.title = radioWin.title }
    }

    // Top bar
    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            Label { text: "Dual RFD900x Chat"; font.bold: true; Layout.alignment: Qt.AlignVCenter; padding: 8 } // simple title label
            Item { Layout.fillWidth: true }                                                                      // spacer pushes button right
            Button { text: "Refresh Ports"; onClicked: bridge.refreshPorts() }                                   // manual rescan of COM list
        }
    }

    // Two-column body (TX on left, RX on right)
    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        // TX column
        Frame {
            Layout.fillWidth: true
            Layout.fillHeight: true
            ColumnLayout {
                anchors.fill: parent; spacing: 8
                Label { text: "Sender (TX)"; font.bold: true; padding: 4 } // section title
                RowLayout {
                    spacing: 8
                    ComboBox {
                        id: txPortSel; model: bridge.ports; Layout.preferredWidth: 160
                        Component.onCompleted: {
                            const i = bridge.ports.indexOf(bridge.txPortName) // preselect current port if already connected
                            if (i >= 0) txPortSel.currentIndex = i
                        }
                    }
                    Button { text: "Refresh"; onClicked: bridge.refreshPorts() } // rescan without leaving window
                    ComboBox {
                        id: txBaudSel; model: baudList; Layout.preferredWidth: 110
                        Component.onCompleted: {
                            const i = baudList.indexOf(bridge.txBaud || 9600) // default to current (or 9600 if unknown)
                            if (i >= 0) txBaudSel.currentIndex = i
                        }
                    }
                    Button {
                        text: bridge.txConnected ? "Disconnect" : "Connect"
                        onClicked: bridge.txConnected
                                  ? bridge.disconnectTxPort()                                 // toggle off if connected
                                  : bridge.connectTxPort(txPortSel.currentText, Number(txBaudSel.currentText)) // open with chosen baud
                    }
                    Label { text: bridge.txConnected ? "Connected" : "—"; color: bridge.txConnected ? "green" : "gray"; Layout.alignment: Qt.AlignVCenter } // quick status
                }
                GroupBox {
                    title: "Type & Send via TX"; Layout.fillWidth: true; Layout.fillHeight: true
                    ColumnLayout {
                        anchors.fill: parent; spacing: 8
                        TextField {
                            id: txInput; placeholderText: "Type text to send…"; Layout.fillWidth: true; enabled: bridge.txConnected // disabled until TX open
                            onAccepted: { if (enterChk.checked) sendBtn.clicked() } // Enter triggers the same handler as button
                        }
                        RowLayout {
                            spacing: 10
                            Button {
                                id: sendBtn; text: "Send"; enabled: bridge.txConnected // guard against sending when closed
                                onClicked: { if (txInput.text.length) { bridge.sendText(txInput.text); txInput.text = "" } } // send and clear input
                            }
                            CheckBox { id: enterChk; text: "Enter to send"; checked: true } // opt into Enter-to-send UX
                            Label { text: `TX → ${bridge.txPortName || "—"}@${bridge.txBaud || "—"}`; color: "gray" } // live TX port/baud hint
                        }
                        Item { Layout.fillHeight: true } // spacer keeps TX and RX columns visually balanced
                    }
                }
            }
        }

        // RX column
        Frame {
            Layout.fillWidth: true
            Layout.fillHeight: true
            ColumnLayout {
                anchors.fill: parent; spacing: 8
                Label { text: "Receiver (RX)"; font.bold: true; padding: 4 } // section title
                RowLayout {
                    spacing: 8
                    ComboBox {
                        id: rxPortSel; model: bridge.ports; Layout.preferredWidth: 160
                        Component.onCompleted: {
                            const i = bridge.ports.indexOf(bridge.rxPortName) // preselect current RX if already connected
                            if (i >= 0) rxPortSel.currentIndex = i
                        }
                    }
                    Button { text: "Refresh"; onClicked: bridge.refreshPorts() } // rescan port list on demand
                    ComboBox {
                        id: rxBaudSel; model: baudList; Layout.preferredWidth: 110
                        Component.onCompleted: {
                            const i = baudList.indexOf(bridge.rxBaud || 9600) // default to current (or 9600 if unknown)
                            if (i >= 0) rxBaudSel.currentIndex = i
                        }
                    }
                    Button {
                        text: bridge.rxConnected ? "Disconnect" : "Connect"
                        onClicked: bridge.rxConnected
                                  ? bridge.disconnectRxPort()                                 // toggle off if connected
                                  : bridge.connectRxPort(rxPortSel.currentText, Number(rxBaudSel.currentText)) // open with chosen baud
                    }
                    Label { text: bridge.rxConnected ? "Connected" : "—"; color: bridge.rxConnected ? "green" : "gray"; Layout.alignment: Qt.AlignVCenter } // quick status
                }
                GroupBox {
                    title: "Received from RX"; Layout.fillWidth: true; Layout.fillHeight: true
                    ColumnLayout {
                        anchors.fill: parent; spacing: 8
                        TextArea { id: rxText; readOnly: true; wrapMode: Text.Wrap; Layout.fillWidth: true; Layout.fillHeight: true; font.family: "Consolas" } // display area for incoming lines
                        RowLayout { Item { Layout.fillWidth: true }  // spacer pushes clear button to the right
                        Button { text: "Clear RX"; onClicked: rxText.text = "" } } // quick way to clear the log
                    }
                }
            }
        }
    }
}


