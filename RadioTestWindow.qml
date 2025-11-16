import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

// Main window for RFD900x single/dual port terminal
ApplicationWindow {
    id: radioWin
    width: 1100
    height: 700
    visible: false

    // ---------- Modes / State ----------

    // true  => Single-port (one port does RX+TX; pause RX while TX)
    // false => Dual-port  (separate RX and TX ports)
    property bool singleMode: true

    // Bridge-side mapping we track locally
    property int rxWhich: 1
    property int txWhich: 2

    // Per-port connection flags and logs
    property bool   p1Connected: bridge.isConnected(1)
    property bool   p2Connected: bridge.isConnected(2)
    property string rxLogP1: ""
    property string rxLogP2: ""

    // Convenience flags for current RX/TX ports
    property bool singleConnected: bridge.isConnected(rxWhich)
    property bool txConnected: bridge.isConnected(txWhich)
    property bool rxConnected: bridge.isConnected(rxWhich)

    // Baud rate options
    property var baudList: [57600, 115200]

    // ---------- Title ----------

    // Build window title according to current mode and port/baud settings
    function titleText() {
        if (singleMode) {
            const n = bridge.portName(rxWhich) || "—"
            const b = bridge.baudRate(rxWhich) || "—"
            return "RFD900x — Single-Port Mode  P" + rxWhich + ": " + n + "@" + b
        } else {
            const tn = bridge.portName(txWhich) || "—"
            const rn = bridge.portName(rxWhich) || "—"
            const tb = bridge.baudRate(txWhich) || "—"
            const rb = bridge.baudRate(rxWhich) || "—"
            return "Dual RFD900x Chat —  TX(P" + txWhich + "): " + tn + "@" + tb +
                   "  |  RX(P" + rxWhich + "): " + rn + "@" + rb
        }
    }
    title: titleText()
    modality: Qt.NonModal
    flags: Qt.Window

    // ---------- Error popup ----------

    // Small non-blocking popup for showing backend error messages
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

    // ---------- Signals from backend ----------

    // Handle bridge signals: errors, port changes, RX text, connection updates
    Connections {
        target: bridge

        // Show error from backend
        function onErrorMessage(msg) {
            errorLabel.text = msg
            errorPopup.open()
        }

        // Refresh combo models and window title when port list changes
        function onPortsChanged() {
            singlePortSel.model = bridge.ports
            radioWin.title = radioWin.titleText()
        }

        // Update title on baud change
        function onBaudChanged(which) {
            if (which === rxWhich || which === txWhich)
                radioWin.title = radioWin.titleText()
        }

        // Update title on port name change
        function onPortNameChanged(which) {
            if (which === rxWhich || which === txWhich)
                radioWin.title = radioWin.titleText()
        }

        // Append incoming text to the correct per-port log
        function onTextReceivedFrom(which, line) {
            if (which === 1)
                rxLogP1 += line + "\n"
            else if (which === 2)
                rxLogP2 += line + "\n"
        }

        // Track connection status per port and for single-mode flag
        function onConnectedChanged(which, connected) {
            if (which === 1) {
                p1Connected = connected
                if (rxWhich === 1)
                    singleConnected = connected
            } else if (which === 2) {
                p2Connected = connected
                if (rxWhich === 2)
                    singleConnected = connected
            }
        }

        // Keep title in sync with backend TX/RX mapping
        function onTxToChanged() { radioWin.title = radioWin.titleText() }
        function onRxFromChanged() { radioWin.title = radioWin.titleText() }
    }

    // ---------- Toolbar (top header) ----------

    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            spacing: 12

            // Mode label
            Label {
                text: singleMode ? "RFD900x — Single-Port" : "RFD900x — Dual-Port"
                font.bold: true
                Layout.alignment: Qt.AlignVCenter
                padding: 8
            }

            Item { Layout.fillWidth: true } // spacer

            // Mode switcher: Single vs Dual
            RowLayout {
                spacing: 6
                Label { text: "Mode:"; Layout.alignment: Qt.AlignVCenter }
                ComboBox {
                    id: modeBox
                    model: ["Single Port", "Dual Port"]
                    currentIndex: singleMode ? 0 : 1
                    onActivated: {
                        // Disconnect all ports when switching mode
                        if (bridge.isConnected(1)) bridge.disconnectPort(1)
                        if (bridge.isConnected(2)) bridge.disconnectPort(2)

                        p1Connected = false
                        p2Connected = false
                        singleConnected = false

                        // Stop periodic timers if present (dual-mode senders)
                        if (typeof timerP1 !== "undefined") timerP1.stop()
                        if (typeof timerP2 !== "undefined") timerP2.stop()

                        // Set new mode and default mapping
                        singleMode = (currentIndex === 0)

                        if (singleMode) {
                            // single: same port for RX+TX
                            rxWhich = 1
                            txWhich = 1
                        } else {
                            // dual: RX=P1, TX=P2 by default
                            rxWhich = 1
                            txWhich = 2
                        }

                        radioWin.title = radioWin.titleText()
                    }
                }
            }

            // Manual port list refresh
            Button { text: "Refresh Ports"; onClicked: bridge.refreshPorts() }
        }
    }

    // ---------- Shared RX text area alias (if ever reused) ----------

    property alias rxTextArea: rxText
    TextArea {
        id: rxText
        visible: false // logical alias only; actual visible RX areas are below
    }

    // ---------- Main Layout: Single vs Dual pages ----------

    // StackLayout switches between single-port page and dual-port page
    StackLayout {
        anchors.fill: parent
        anchors.margins: 12
        currentIndex: singleMode ? 0 : 1

        // ===== Page 0: Single-Port Mode =====
        Item {
            // One-column layout: config on top, IO (send/RX) below
            ColumnLayout {
                anchors.fill: parent
                spacing: 10

                // ---- Single-port configuration ----
                Frame {
                    Layout.fillWidth: true
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 8

                        Label { text: "Single-Port (RX + TX)"; font.bold: true; padding: 4 }

                        RowLayout {
                            spacing: 8

                            // Choose which physical port index (1 or 2)
                            Label { text: "Use physical:"; Layout.alignment: Qt.AlignVCenter }
                            ComboBox {
                                id: singleWhichSel
                                model: [1, 2]
                                Layout.preferredWidth: 90
                                Component.onCompleted: currentIndex = (rxWhich === 2 ? 1 : 0)
                                onActivated: {
                                    const w = Number(currentText)
                                    rxWhich = w
                                    txWhich = w
                                    // Update backend mapping if connected
                                    if (bridge.isConnected(w)) {
                                        bridge.setRxFrom(w)
                                        bridge.setTxTo(w)
                                    }
                                    radioWin.title = radioWin.titleText()
                                }
                            }

                            // OS serial port selection
                            ComboBox {
                                id: singlePortSel
                                model: bridge.ports
                                Layout.preferredWidth: 220
                                Component.onCompleted: {
                                    const name = bridge.portName(rxWhich)
                                    const i = model.indexOf(name)
                                    currentIndex = (i >= 0 ? i : -1)
                                }
                            }

                            // Quick refresh for single-mode port list
                            Button { text: "Refresh"; onClicked: bridge.refreshPorts() }

                            // Baud rate for single port
                            ComboBox {
                                id: singleBaudSel
                                model: baudList
                                Layout.preferredWidth: 120
                                Component.onCompleted: {
                                    const i = baudList.indexOf(bridge.baudRate(rxWhich) || 57600)
                                    currentIndex = (i >= 0 ? i : 0)
                                }
                            }

                            // Connect / Disconnect button for single-mode
                            Button {
                              id: singleConnBtn
                              text: singleConnected ? "Disconnect" : "Connect"
                              onClicked: {
                                if (singleConnected) {
                                  bridge.disconnectPort(rxWhich)
                                  singleConnected = false      // immediate UI feedback
                                } else {
                                  if (singlePortSel.currentIndex >= 0) {
                                    if (bridge.connectPort(rxWhich, singlePortSel.currentText, Number(singleBaudSel.currentText))) {
                                      bridge.setRxFrom(rxWhich)
                                      bridge.setTxTo(rxWhich)
                                      singleConnected = true   // immediate UI feedback
                                    }
                                  } else {
                                    errorLabel.text = "Select a COM port first."
                                    errorPopup.open()
                                  }
                                }
                                radioWin.title = radioWin.titleText()
                              }
                            }

                            // Connection status indicator
                            Label {
                              text: singleConnected ? "Connected" : "—"
                              color: singleConnected ? "green" : "gray"
                            }

                        }
                    }
                }

                // ---- Single-port IO area (send + receive) ----
                Frame {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 8

                        // Send text box (enter to send)
                        GroupBox {
                            title: "Type & Send (press Enter)"
                            Layout.fillWidth: true
                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 8

                                TextField {
                                    id: singleInput
                                    placeholderText: "Type text and press Enter…"
                                    Layout.fillWidth: true
                                    enabled: bridge.isConnected(rxWhich)
                                    focus: true
                                    onAccepted: {
                                        if (text.length && bridge.isConnected(rxWhich)) {
                                            bridge.sendText(rxWhich, text)
                                            text = ""
                                        }
                                    }
                                }
                            }
                        }

                        // Received messages panel
                        GroupBox {
                            title: "Received"
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 4

                                // Scrollable RX view
                                Flickable {
                                    id: flickSingle
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    clip: true

                                    contentWidth: singleRxText.paintedWidth
                                    contentHeight: singleRxText.paintedHeight

                                    ScrollBar.vertical: ScrollBar {
                                        policy: ScrollBar.AsNeeded
                                    }

                                    // Text area bound to active single-mode RX log
                                    TextEdit {
                                        id: singleRxText
                                        readOnly: true
                                        wrapMode: TextEdit.Wrap
                                        width: flickSingle.width
                                        font.family: "Consolas"
                                        text: (rxWhich === 1 ? rxLogP1 : rxLogP2)

                                        // Auto-scroll to bottom on new text
                                        onTextChanged: {
                                            flickSingle.contentY = Math.max(0, flickSingle.contentHeight - flickSingle.height)
                                        }
                                    }
                                }

                                // Clear button for current RX log
                                RowLayout {
                                    Layout.alignment: Qt.AlignRight
                                    Button {
                                        text: "Clear RX"
                                        onClicked: {
                                            if (rxWhich === 1)
                                                rxLogP1 = ""
                                            else
                                                rxLogP2 = ""
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // ===== Page 1: Dual-Port Mode =====
        Item {
            id: dualModePage

            // Local per-port state for dual mode
            property string rxLogP1: ""
            property string rxLogP2: ""
            property bool   p1Connected: bridge.isConnected(1)
            property bool   p2Connected: bridge.isConnected(2)

            // Two-column layout: Port 1 on left, Port 2 on right
            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12

                // ------------------- PORT 1 COLUMN -------------------
                Frame {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 8

                        Label { text: "Port 1"; font.bold: true; padding: 4 }

                        // --- Port 1 config row (port, baud, connect, refresh) ---
                        RowLayout {
                            spacing: 8

                            // OS port selection for P1
                            ComboBox {
                                id: portSel1
                                model: bridge.ports
                                Layout.preferredWidth: 160
                                Component.onCompleted: {
                                    const name = bridge.portName(1)
                                    const i = model.indexOf(name)
                                    currentIndex = (i >= 0 ? i : -1)
                                }
                            }

                            // Baud selection for P1
                            ComboBox {
                                id: baudSel1
                                model: [57600, 115200]
                                Layout.preferredWidth: 80
                                Component.onCompleted: {
                                    const i = baudSel1.model.indexOf(bridge.baudRate(1) || 57600)
                                    currentIndex = (i >= 0 ? i : 0)
                                }
                            }

                            // Connect / Disconnect button for P1
                            Button {
                                id: connBtn1
                                text: p1Connected ? "Disconnect" : "Connect"
                                Layout.preferredWidth: Math.max(implicitWidth, 100)
                                onClicked: {
                                    if (p1Connected) {
                                        bridge.disconnectPort(1)
                                        p1Connected = false
                                        timerP1.stop()
                                    } else {
                                        if (portSel1.currentIndex >= 0) {
                                            if (bridge.connectPort(1,
                                                                   portSel1.currentText,
                                                                   Number(baudSel1.currentText)))
                                                p1Connected = true
                                        } else {
                                            errorLabel.text = "Pick a COM port for P1."
                                            errorPopup.open()
                                        }
                                    }
                                }
                            }

                            // Refresh port list for P1 side
                            Button {
                                text: "Refresh"
                                Layout.preferredWidth: Math.max(implicitWidth, 80)
                                onClicked: bridge.refreshPorts()
                            }

                            // Connection indicator for P1
                            Label {
                                text: p1Connected ? "Connected" : "—"
                                color: p1Connected ? "green" : "gray"
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        // --- Port 1 send (single shot + periodic) ---
                        GroupBox {
                            title: "Send (P1)"
                            Layout.fillWidth: true
                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 8

                                // One-shot send from P1
                                TextField {
                                    id: sendOnce1
                                    placeholderText: "Type and press Enter to send from P1…"
                                    Layout.fillWidth: true
                                    enabled: p1Connected
                                    onAccepted: {
                                        if (text.length && p1Connected) {
                                            bridge.sendText(1, text)
                                            text = ""
                                        }
                                    }
                                }

                                // Periodic send controls for P1
                                RowLayout {
                                    spacing: 10

                                    TextField {
                                        id: periodicMsg1
                                        placeholderText: "Periodic message (P1)…"
                                        Layout.preferredWidth: 230
                                    }

                                    // Frequency selection (Hz) for periodic sends
                                    RowLayout {
                                        spacing: 6
                                        SpinBox {
                                            id: hz1
                                            from: 1; to: 200; value: 50
                                            editable: true
                                        }
                                        Label { text: "Hz"; Layout.alignment: Qt.AlignVCenter }
                                    }

                                    // Start/Stop buttons for P1 periodic sender
                                    Button {
                                        id: startP1
                                        text: "Start"
                                        enabled: p1Connected
                                        onClicked: {
                                            timerP1.interval = Math.max(1, Math.floor(1000 / hz1.value))
                                            timerP1.start()
                                        }
                                    }
                                    Button {
                                        text: "Stop"
                                        onClicked: timerP1.stop()
                                    }
                                }

                                // Timer to drive P1 periodic sending
                                Timer {
                                    id: timerP1
                                    repeat: true
                                    running: false
                                    interval: 20
                                    onTriggered: {
                                        if (p1Connected && periodicMsg1.text.length) {
                                            bridge.sendText(1, periodicMsg1.text)
                                        }
                                    }
                                }
                            }
                        }

                        // --- Port 1 receive area ---
                        GroupBox {
                            title: "Received (P1)"
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 4

                                // Scrollable RX view for P1
                                Flickable {
                                    id: flickP1
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    clip: true

                                    contentWidth: rxTextP1.paintedWidth
                                    contentHeight: rxTextP1.paintedHeight

                                    ScrollBar.vertical: ScrollBar {
                                        policy: ScrollBar.AsNeeded
                                    }

                                    // RX text viewer bound to P1 log
                                    TextEdit {
                                        id: rxTextP1
                                        readOnly: true
                                        wrapMode: TextEdit.Wrap
                                        width: flickP1.width
                                        font.family: "Consolas"
                                        text: rxLogP1

                                        // Auto-scroll to bottom on new RX text
                                        onTextChanged: {
                                            flickP1.contentY = Math.max(0, flickP1.contentHeight - flickP1.height)
                                        }
                                    }
                                }

                                // Clear P1 RX log
                                RowLayout {
                                    Layout.alignment: Qt.AlignRight
                                    Button {
                                        text: "Clear"
                                        onClicked: rxLogP1 = ""
                                    }
                                }
                            }
                        }
                    }
                }

                // ------------------- PORT 2 COLUMN -------------------
                Frame {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 8

                        Label { text: "Port 2"; font.bold: true; padding: 4 }

                        // --- Port 2 config row (port, baud, connect, refresh) ---
                        RowLayout {
                            spacing: 8

                            // OS port selection for P2
                            ComboBox {
                                id: portSel2
                                model: bridge.ports
                                Layout.preferredWidth: 160
                                Component.onCompleted: {
                                    const name = bridge.portName(2)
                                    const i = model.indexOf(name)
                                    currentIndex = (i >= 0 ? i : -1)
                                }
                            }

                            // Baud selection for P2
                            ComboBox {
                                id: baudSel2
                                model: [57600, 115200]
                                Layout.preferredWidth: 80
                                Component.onCompleted: {
                                    const i = baudSel2.model.indexOf(bridge.baudRate(2) || 57600)
                                    currentIndex = (i >= 0 ? i : 0)
                                }
                            }

                            // Connect / Disconnect button for P2
                            Button {
                                id: connBtn2
                                text: p2Connected ? "Disconnect" : "Connect"
                                Layout.preferredWidth: Math.max(implicitWidth, 100)
                                onClicked: {
                                    if (p2Connected) {
                                        bridge.disconnectPort(2)
                                        p2Connected = false
                                        timerP2.stop()
                                    } else {
                                        if (portSel2.currentIndex >= 0) {
                                            if (bridge.connectPort(2,
                                                                   portSel2.currentText,
                                                                   Number(baudSel2.currentText)))
                                                p2Connected = true
                                        } else {
                                            errorLabel.text = "Pick a COM port for P2."
                                            errorPopup.open()
                                        }
                                    }
                                }
                            }

                            // Refresh port list for P2 side
                            Button {
                                text: "Refresh"
                                Layout.preferredWidth: Math.max(implicitWidth, 80)
                                onClicked: bridge.refreshPorts()
                            }

                            // Connection indicator for P2
                            Label {
                                text: p2Connected ? "Connected" : "—"
                                color: p2Connected ? "green" : "gray"
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        // --- Port 2 send (single shot + periodic) ---
                        GroupBox {
                            title: "Send (P2)"
                            Layout.fillWidth: true
                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 8

                                // One-shot send from P2
                                TextField {
                                    id: sendOnce2
                                    placeholderText: "Type and press Enter to send from P2…"
                                    Layout.fillWidth: true
                                    enabled: p2Connected
                                    onAccepted: {
                                        if (text.length && p2Connected) {
                                            bridge.sendText(2, text)
                                            text = ""
                                        }
                                    }
                                }

                                // Periodic send controls for P2
                                RowLayout {
                                    spacing: 10

                                    TextField {
                                        id: periodicMsg2
                                        placeholderText: "Periodic message (P2)…"
                                        Layout.preferredWidth: 230
                                    }

                                    // Frequency selection (Hz) for P2 periodic send
                                    RowLayout {
                                        spacing: 6
                                        SpinBox {
                                            id: hz2
                                            from: 1; to: 200; value: 50
                                            editable: true
                                        }
                                        Label { text: "Hz"; Layout.alignment: Qt.AlignVCenter }
                                    }

                                    // Start/Stop buttons for P2 periodic sender
                                    Button {
                                        id: startP2
                                        text: "Start"
                                        enabled: p2Connected
                                        onClicked: {
                                            timerP2.interval = Math.max(1, Math.floor(1000 / hz2.value))
                                            timerP2.start()
                                        }
                                    }
                                    Button {
                                        text: "Stop"
                                        onClicked: timerP2.stop()
                                    }
                                }

                                // Timer to drive P2 periodic sending
                                Timer {
                                    id: timerP2
                                    repeat: true
                                    running: false
                                    interval: 20
                                    onTriggered: {
                                        if (p2Connected && periodicMsg2.text.length) {
                                            bridge.sendText(2, periodicMsg2.text)
                                        }
                                    }
                                }
                            }
                        }

                        // --- Port 2 receive area ---
                        GroupBox {
                            title: "Received (P2)"
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 4

                                // Scrollable RX view for P2
                                Flickable {
                                    id: flickP2
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    clip: true

                                    contentWidth: rxTextP2.paintedWidth
                                    contentHeight: rxTextP2.paintedHeight

                                    ScrollBar.vertical: ScrollBar {
                                        policy: ScrollBar.AsNeeded
                                    }

                                    // RX text viewer bound to P2 log
                                    TextEdit {
                                        id: rxTextP2
                                        readOnly: true
                                        wrapMode: TextEdit.Wrap
                                        width: flickP2.width
                                        font.family: "Consolas"
                                        text: rxLogP2

                                        // Auto-scroll to bottom on new text
                                        onTextChanged: {
                                            flickP2.contentY = Math.max(0, flickP2.contentHeight - flickP2.height)
                                        }
                                    }
                                }

                                // Clear P2 RX log
                                RowLayout {
                                    Layout.alignment: Qt.AlignRight
                                    Button {
                                        text: "Clear"
                                        onClicked: rxLogP2 = ""
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
