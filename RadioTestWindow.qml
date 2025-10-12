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
           + (bridge.txPortName || "—") + "@" + (bridge.txBaud || "—")
           + "  |  RX: " + (bridge.rxPortName || "—") + "@" + (bridge.rxBaud || "—")
    modality: Qt.NonModal     // floats over your main window
    flags: Qt.Window

    // Common baud list + minor state
    property var baudList: [9600, 57600, 115200]

    // Error banner
    Popup {
        id: errorPopup
        x: 16; y: 16
        modal: false; focus: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        contentItem: Frame { padding: 10; Label { id: errorLabel; wrapMode: Text.Wrap; text: "" } }
    }

    // Backend signals
    Connections {
        target: bridge
        function onErrorMessage(msg) { errorLabel.text = msg; errorPopup.open() }
        function onRxTextRecieved(line) { rxText.append(line + "\n") }
        function onTxPortNameChanged() { radioWin.title = radioWin.title }
        function onRxPortNameChanged() { radioWin.title = radioWin.title }
        function onTxBaudChanged()     { radioWin.title = radioWin.title }
        function onRxBaudChanged()     { radioWin.title = radioWin.title }
        function onTxConnectedChanged(){ radioWin.title = radioWin.title }
        function onRxConnectedChanged(){ radioWin.title = radioWin.title }
    }

    // Top bar
    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            Label { text: "Dual RFD900x Chat"; font.bold: true; Layout.alignment: Qt.AlignVCenter; padding: 8 }
            Item { Layout.fillWidth: true }
            Button { text: "Refresh Ports"; onClicked: bridge.refreshPorts() }
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
                Label { text: "Sender (TX)"; font.bold: true; padding: 4 }
                RowLayout {
                    spacing: 8
                    ComboBox {
                        id: txPortSel; model: bridge.ports; Layout.preferredWidth: 160
                        Component.onCompleted: {
                            const i = bridge.ports.indexOf(bridge.txPortName)
                            if (i >= 0) txPortSel.currentIndex = i
                        }
                    }
                    Button { text: "Refresh"; onClicked: bridge.refreshPorts() }
                    ComboBox {
                        id: txBaudSel; model: baudList; Layout.preferredWidth: 110
                        Component.onCompleted: {
                            const i = baudList.indexOf(bridge.txBaud || 9600)
                            if (i >= 0) txBaudSel.currentIndex = i
                        }
                    }
                    Button {
                        text: bridge.txConnected ? "Disconnect" : "Connect"
                        onClicked: bridge.txConnected
                                  ? bridge.disconnectTxPort()
                                  : bridge.connectTxPort(txPortSel.currentText, Number(txBaudSel.currentText))
                    }
                    Label { text: bridge.txConnected ? "Connected" : "—"; color: bridge.txConnected ? "green" : "gray"; Layout.alignment: Qt.AlignVCenter }
                }
                GroupBox {
                    title: "Type & Send via TX"; Layout.fillWidth: true; Layout.fillHeight: true
                    ColumnLayout {
                        anchors.fill: parent; spacing: 8
                        TextField {
                            id: txInput; placeholderText: "Type text to send…"; Layout.fillWidth: true; enabled: bridge.txConnected
                            onAccepted: { if (enterChk.checked) sendBtn.clicked() }
                        }
                        RowLayout {
                            spacing: 10
                            Button {
                                id: sendBtn; text: "Send"; enabled: bridge.txConnected
                                onClicked: { if (txInput.text.length) { bridge.sendText(txInput.text); txInput.text = "" } }
                            }
                            CheckBox { id: enterChk; text: "Enter to send"; checked: true }
                            Label { text: `TX → ${bridge.txPortName || "—"}@${bridge.txBaud || "—"}`; color: "gray" }
                        }
                        Item { Layout.fillHeight: true }
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
                Label { text: "Receiver (RX)"; font.bold: true; padding: 4 }
                RowLayout {
                    spacing: 8
                    ComboBox {
                        id: rxPortSel; model: bridge.ports; Layout.preferredWidth: 160
                        Component.onCompleted: {
                            const i = bridge.ports.indexOf(bridge.rxPortName)
                            if (i >= 0) rxPortSel.currentIndex = i
                        }
                    }
                    Button { text: "Refresh"; onClicked: bridge.refreshPorts() }
                    ComboBox {
                        id: rxBaudSel; model: baudList; Layout.preferredWidth: 110
                        Component.onCompleted: {
                            const i = baudList.indexOf(bridge.rxBaud || 9600)
                            if (i >= 0) rxBaudSel.currentIndex = i
                        }
                    }
                    Button {
                        text: bridge.rxConnected ? "Disconnect" : "Connect"
                        onClicked: bridge.rxConnected
                                  ? bridge.disconnectRxPort()
                                  : bridge.connectRxPort(rxPortSel.currentText, Number(rxBaudSel.currentText))
                    }
                    Label { text: bridge.rxConnected ? "Connected" : "—"; color: bridge.rxConnected ? "green" : "gray"; Layout.alignment: Qt.AlignVCenter }
                }
                GroupBox {
                    title: "Received from RX"; Layout.fillWidth: true; Layout.fillHeight: true
                    ColumnLayout {
                        anchors.fill: parent; spacing: 8
                        TextArea { id: rxText; readOnly: true; wrapMode: Text.Wrap; Layout.fillWidth: true; Layout.fillHeight: true; font.family: "Consolas" }
                        RowLayout { Item { Layout.fillWidth: true }
                        Button { text: "Clear RX"; onClicked: rxText.text = "" } }
                    }
                }
            }
        }
    }
}

