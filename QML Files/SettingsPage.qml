import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import "Items"

ApplicationWindow {
    id: settingsWin
    width: 1100
    height: 700
    visible: false

    Rectangle {
        //Initialize the actual content board
        id: contentBoard

        width: parent.width - 4
        height: parent.height - 4
        color: "#111827"
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }
    }


    // --- Custom Styled Components ---
    component StyledCheckBox : CheckBox {
        id: cb
        spacing: 10

        indicator: Rectangle {
            implicitWidth: 18
            implicitHeight: 18
            radius: 4
            color: "#1c2a40"
            border.color: cb.checked ? "#87c0fa" : "#2c3e50"
            border.width: cb.activeFocus ? 2 : 1

            Rectangle {
                anchors.centerIn: parent
                width: 10; height: 10
                radius: 2
                visible: cb.checked
                color: "#87c0fa"
            }
        }

        contentItem: Text {
            text: cb.text
            color: "white"
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 14

            leftPadding: indicator.width + 10
        }
    }

    component StyledComboBox : ComboBox {
        id: box
        implicitHeight: 40

        contentItem: Text {
            text: box.displayText
            color: "white"
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            leftPadding: 10
            rightPadding: 28
        }

        background: Rectangle {
            radius: 5
            color: "#1c2a40"
            border.color: box.activeFocus ? "#87c0fa" : "#2c3e50"
            border.width: 1
        }

        indicator: Text {
            text: "▾"
            color: "#87c0fa"
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 14
        }

    }

    component StyledButton : Button {
        id: btn
        background: Rectangle {
            implicitWidth: 100
            implicitHeight: 40
            color: btn.down ? "#2c3e50" : (btn.hovered ? "#25354a" : "#1c2a40")
            border.color: "#87c0fa"
            border.width: btn.activeFocus ? 2 : 1
            radius: 5
        }
        contentItem: Text {
            text: btn.text
            color: btn.enabled ? "#87c0fa" : "#555555"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.bold: true
        }
    }

    component StyledFrame : Rectangle {
        // Standard Rectangle doesn't have a "background" property,
        // so we use the Rectangle itself as the container.
        color: "transparent"
        border.color: "#2c3e50"
        radius: 5
        border.width: 1
        clip: true
    }

    component StyledTextField : TextField {
        id: txtInput
        color: "white"
        placeholderTextColor: "#888888"
        padding: 10
        background: Rectangle {
            color: "#1c2a40"
            border.color: txtInput.activeFocus ? "#87c0fa" : "#2c3e50"
            radius: 5
        }
    }


    // --- Main Layout ---
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // LEFT SIDEBAR
        Rectangle {
            color: "#1F2937"
            border.color: "#2d3748"
            border.width: 4
            radius: 8

            height: 700
            width: 250

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                Text { text: "Settings"; font.bold: true; font.pixelSize: 22; color: "#87c0fa" }

                Item { height: 20 }

                Item {
                    id: radioController

                    property var radioConsole: null

                    Component {
                        id: radioConsoleComponent
                        RadioTestWindow { }
                    }

                    function openRadioConsole() {
                        if (!radioConsole) {
                            radioConsole = radioConsoleComponent.createObject(window, {
                                x: window.x + 310,
                                y: window.y + 60
                            })
                        }
                        radioConsole.show()
                        radioConsole.raise()
                        radioConsole.requestActivate()
                    }
                }

                StyledButton {
                    text: "Data Display"
                    Layout.fillWidth: true
                    onClicked: mainStack.currentIndex = 0
                }

                StyledButton {
                    text: "Open Radio Console"
                    Layout.fillWidth: true
                    onClicked: radioController.openRadioConsole()
                }

                StyledButton {
                    text: "PID values"
                    Layout.fillWidth: true
                    onClicked: mainStack.currentIndex = 1
                }

                Item { Layout.fillHeight: true }
            }
        }

        Rectangle {
            color: "#1F2937"
            border.color: "#2d3748"
            border.width: 4
            radius: 8
            height: 700
            width: 850

            // RIGHT CONTENT AREA
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 30
                spacing: 20
                Layout.margins: 30

                StackLayout {
                    id: mainStack
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    // ---------------------------
                    // PAGE 0: DATA DISPLAY CONFIG
                    // ---------------------------
                    Item {
                        id: dataDisplayPage
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        property var columnsModel: [
                            {
                                title: "Left Column",
                                rows: [
                                    {
                                        title: "Kalman Angles (deg)",
                                        fields: [
                                            { key: "raw_angle_x",      label: "Raw Angle X"       },
                                            { key: "filtered_angle_x", label: "Filtered Angle X"  },
                                            { key: "raw_angle_y",      label: "Raw Angle Y"       },
                                            { key: "filtered_angle_y", label: "Filtered Angle Y"  },
                                            { key: "raw_angle_z",      label: "Raw Angle Z"       },
                                            { key: "filtered_angle_z", label: "Filtered Angle Z"  }
                                        ]
                                    },
                                    {
                                        title: "Engine Control",
                                        fields: [
                                            { key: "throttle", label: "Throttle" },
                                            { key: "fuel",     label: "Fuel" }
                                        ]
                                    }
                                ]
                            },
                            {
                                title: "Right Column",
                                rows: [
                                    {
                                        title: "",
                                        fields: [
                                            { key: "pressure",    label: "Pressure (hPa)" },
                                            { key: "altitude",    label: "Altitude (m)" },
                                            { key: "velocity",    label: "Velocity" },
                                            { key: "temperature", label: "Temperature" },
                                            { key: "signals",     label: "Signal" },
                                            { key: "battery",     label: "Battery" }
                                        ]
                                    }
                                ]
                            }
                        ]
                        property int modelRev: 0
                        function bumpRev() { modelRev++ }

                        function cloneColumnsModel() {
                            // data-only model => JSON clone is fine
                            return JSON.parse(JSON.stringify(columnsModel))
                        }

                        function normalizeKey(s) { // lightweight key normalization
                            var t = (s || "").trim().toLowerCase()
                            t = t.replace(/\s+/g, "_").replace(/[^\w]/g, "")
                            return t
                        }

                        function collectSelectedKeys() {
                            // Now: all items in the layout are “selected” (displayed)
                            var selected = []
                            for (var c = 0; c < columnsModel.length; c++) {
                                for (var r = 0; r < columnsModel[c].rows.length; r++) {
                                    var fields = columnsModel[c].rows[r].fields
                                    for (var f = 0; f < fields.length; f++)
                                        selected.push(fields[f].key)
                                }
                            }
                            return selected
                        }

                        function hasKeyInRow(colIndex, rowIndex, key) {
                            var fields = columnsModel[colIndex].rows[rowIndex].fields
                            for (var i = 0; i < fields.length; i++)
                                if (fields[i].key === key) return true
                            return false
                        }

                        function removeRow(colIndex, rowIndex) {
                            if (colIndex < 0 || colIndex >= columnsModel.length) return

                            // clone -> mutate clone -> assign back
                            var m = cloneColumnsModel()

                            var rows = m[colIndex].rows
                            if (!rows) return
                            if (rowIndex < 0 || rowIndex >= rows.length) return

                            rows.splice(rowIndex, 1)

                            columnsModel = m   // IMPORTANT: triggers QML update
                        }

                        function addFieldToRow(colIndex, rowIndex, labelText) {
                            var label = (labelText || "").trim()
                            if (!label.length) return

                            var key = normalizeKey(label)
                            if (!key.length) return

                            // clone -> mutate clone -> assign back
                            var m = cloneColumnsModel()

                            // duplicate check on clone
                            var fields = m[colIndex].rows[rowIndex].fields
                            for (var i = 0; i < fields.length; i++)
                                if (fields[i].key === key) return

                            fields.push({ key: key, label: label })
                            columnsModel = m
                        }

                        function removeFieldFromRow(colIndex, rowIndex, fieldIndex) {
                            var m = cloneColumnsModel()

                            var fields = m[colIndex].rows[rowIndex].fields
                            if (fieldIndex < 0 || fieldIndex >= fields.length) return

                            fields.splice(fieldIndex, 1)
                            columnsModel = m
                        }

                        function setColumnTitle(colIndex, newTitle) {
                            var m = cloneColumnsModel()
                            m[colIndex].title = newTitle
                            columnsModel = m
                        }

                        function setRowTitle(colIndex, rowIndex, newTitle) {
                            var m = cloneColumnsModel()
                            m[colIndex].rows[rowIndex].title = newTitle
                            columnsModel = m
                        }

                        function addRow(colIndex, rowTitle) {
                            var m = cloneColumnsModel()
                            m[colIndex].rows.push({ title: rowTitle || "New Row", fields: [] })
                            columnsModel = m
                        }


                        RowLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            anchors.fill: parent
                            spacing: 16

                            // -------- Column 0 (Left) --------
                            StyledFrame {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Rectangle { anchors.fill: parent; color: "#121b29"; opacity: 0.20 }

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    spacing: 12

                                    // Column title (editable)
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 10
                                        StyledTextField {
                                            Layout.fillWidth: true
                                            text: dataDisplayPage.columnsModel[0].title
                                            placeholderText: "Column name"
                                            onEditingFinished: dataDisplayPage.setColumnTitle(0, text)
                                        }

                                        StyledButton {
                                            text: "ADD ROW"
                                            Layout.preferredWidth: 120
                                            onClicked: dataDisplayPage.addRow(0, "New Row")
                                        }
                                    }

                                    // Rows
                                    Flickable {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        clip: true
                                        contentHeight: col0Content.implicitHeight

                                        ColumnLayout {
                                            id: col0Content
                                            width: parent.width
                                            spacing: 12

                                            Repeater {
                                                model: dataDisplayPage.columnsModel[0].rows

                                                delegate: StyledFrame {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: Math.max(120, rowContent.implicitHeight + 18)

                                                    Rectangle { anchors.fill: parent; color: "#1c2a40"; opacity: 0.55 }

                                                    property int rowIndex: index   // keep this on the row delegate

                                                    ColumnLayout {
                                                        id: rowContent
                                                        anchors.fill: parent
                                                        anchors.margins: 12
                                                        spacing: 10

                                                        RowLayout {
                                                            id: rowContentHead
                                                            Layout.fillWidth: true
                                                            spacing: 10

                                                            // Row title (editable) — this is why you see no row name right now
                                                            StyledTextField {
                                                                Layout.fillWidth: true
                                                                text: modelData.title
                                                                placeholderText: "Row name (optional)"
                                                                onEditingFinished: dataDisplayPage.setRowTitle(0, rowIndex, text)
                                                            }

                                                            StyledButton {
                                                                text: "DEL"
                                                                Layout.preferredWidth: 70
                                                                Layout.preferredHeight: 40
                                                                onClicked: dataDisplayPage.removeRow(0, rowIndex)
                                                            }
                                                        }

                                                        // Fields list (robust)
                                                        ListView {
                                                            id: fieldsView
                                                            Layout.fillWidth: true
                                                            Layout.preferredHeight: contentHeight   // row grows with content
                                                            interactive: false                      // parent Flickable handles scrolling
                                                            clip: true
                                                            spacing: 8

                                                            model: modelData.fields

                                                            delegate: StyledFrame {
                                                                width: fieldsView.width
                                                                height: 58

                                                                Rectangle { anchors.fill: parent; color: "#121b29"; opacity: 0.25 }

                                                                RowLayout {
                                                                    anchors.fill: parent
                                                                    anchors.margins: 10
                                                                    spacing: 10

                                                                    Text {
                                                                        text: modelData.label
                                                                        color: "white"
                                                                        elide: Text.ElideRight
                                                                        Layout.fillWidth: true
                                                                        verticalAlignment: Text.AlignVCenter
                                                                    }

                                                                    StyledButton {
                                                                        text: "-"
                                                                        Layout.preferredWidth: 44
                                                                        onClicked: dataDisplayPage.removeFieldFromRow(0, rowIndex, index)
                                                                    }
                                                                }
                                                            }

                                                            // "+" line is a footer item
                                                            footer: StyledFrame {
                                                                width: fieldsView.width
                                                                height: 58

                                                                Rectangle { anchors.fill: parent; color: "#121b29"; opacity: 0.15 }

                                                                RowLayout {
                                                                    anchors.fill: parent
                                                                    anchors.margins: 10
                                                                    spacing: 10

                                                                    StyledTextField {
                                                                        id: addFieldInputLeft
                                                                        Layout.fillWidth: true
                                                                        placeholderText: "Add data to this row…"
                                                                    }

                                                                    StyledButton {
                                                                        text: "+"
                                                                        Layout.preferredWidth: 44
                                                                        onClicked: {
                                                                            dataDisplayPage.addFieldToRow(0, rowIndex, addFieldInputLeft.text)
                                                                            addFieldInputLeft.text = ""
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
                                }
                            }

                            // -------- Column 1 (Right) --------
                            StyledFrame {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Rectangle { anchors.fill: parent; color: "#121b29"; opacity: 0.20 }

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    spacing: 12

                                    // Column title (editable)
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 10
                                        StyledTextField {
                                            Layout.fillWidth: true
                                            text: dataDisplayPage.columnsModel[1].title
                                            placeholderText: "Column name"
                                            onEditingFinished: dataDisplayPage.setColumnTitle(1, text)
                                        }

                                        StyledButton {
                                            text: "ADD ROW"
                                            Layout.preferredWidth: 120
                                            onClicked: dataDisplayPage.addRow(1, "New Row")
                                        }
                                    }

                                    // Rows
                                    Flickable {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        clip: true
                                        contentHeight: col1Content.implicitHeight

                                        ColumnLayout {
                                            id: col1Content
                                            width: parent.width
                                            spacing: 12

                                            Repeater {
                                                model: dataDisplayPage.columnsModel[1].rows

                                                delegate: StyledFrame {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: Math.max(120, rowContent2.implicitHeight + 18)

                                                    Rectangle { anchors.fill: parent; color: "#1c2a40"; opacity: 0.55 }

                                                    property int rowIndex: index   // keep this on the row delegate

                                                    ColumnLayout {
                                                        id: rowContent2
                                                        anchors.fill: parent
                                                        anchors.margins: 12
                                                        spacing: 10

                                                        // Row title (editable) — this is why you see no row name right now
                                                        RowLayout {
                                                            id: rowContentHead2
                                                            Layout.fillWidth: true
                                                            spacing: 10

                                                            // Row title (editable) — this is why you see no row name right now
                                                            StyledTextField {
                                                                Layout.fillWidth: true
                                                                text: modelData.title
                                                                placeholderText: "Row name (optional)"
                                                                onEditingFinished: dataDisplayPage.setRowTitle(1, rowIndex, text)
                                                            }

                                                            StyledButton {
                                                                text: "DEL"
                                                                Layout.preferredWidth: 70
                                                                Layout.preferredHeight: 40
                                                                onClicked: dataDisplayPage.removeRow(1, rowIndex)
                                                            }
                                                        }

                                                        // Fields list (robust)
                                                        ListView {
                                                            id: fieldsView2
                                                            Layout.fillWidth: true
                                                            Layout.preferredHeight: contentHeight   // row grows with content
                                                            interactive: false                      // parent Flickable handles scrolling
                                                            clip: true
                                                            spacing: 8

                                                            model: modelData.fields

                                                            delegate: StyledFrame {
                                                                width: fieldsView2.width
                                                                height: 58

                                                                Rectangle { anchors.fill: parent; color: "#121b29"; opacity: 0.25 }

                                                                RowLayout {
                                                                    anchors.fill: parent
                                                                    anchors.margins: 10
                                                                    spacing: 10

                                                                    Text {
                                                                        text: modelData.label
                                                                        color: "white"
                                                                        elide: Text.ElideRight
                                                                        Layout.fillWidth: true
                                                                        verticalAlignment: Text.AlignVCenter
                                                                    }

                                                                    StyledButton {
                                                                        text: "-"
                                                                        Layout.preferredWidth: 44
                                                                        onClicked: dataDisplayPage.removeFieldFromRow(1, rowIndex, index)
                                                                    }
                                                                }
                                                            }

                                                            // "+" line is a footer item
                                                            footer: StyledFrame {
                                                                width: fieldsView2.width
                                                                height: 58

                                                                Rectangle { anchors.fill: parent; color: "#121b29"; opacity: 0.15 }

                                                                RowLayout {
                                                                    anchors.fill: parent
                                                                    anchors.margins: 10
                                                                    spacing: 10

                                                                    StyledTextField {
                                                                        id: addFieldInputRight
                                                                        Layout.fillWidth: true
                                                                        placeholderText: "Add data to this row…"
                                                                    }

                                                                    StyledButton {
                                                                        text: "+"
                                                                        Layout.preferredWidth: 44
                                                                        onClicked: {
                                                                            dataDisplayPage.addFieldToRow(1, rowIndex, addFieldInputRight.text)
                                                                            addFieldInputRight.text = ""
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
                                }
                            }

                        }
                    }

                    Item {
                        id: pidValuesPage
                        Layout.fillWidth: true
                        Layout.fillHeight: true

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

                                pidPage.pidGainsUpdated(current.mode, pVal, iVal, dVal)
                            }
                            editorPopup.close()
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 16

                            // Title row matches your Data Display style
                            StyledFrame {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 60

                                Rectangle { anchors.fill: parent; color: "#121b29"; opacity: 0.35 }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    spacing: 10

                                    Text {
                                        text: "PID Controller"
                                        color: "#87c0fa"
                                        font.bold: true
                                        font.pixelSize: 22
                                        Layout.fillWidth: true
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    /*
                                    StyledButton {
                                        text: "EDIT PID VALUES"
                                        Layout.preferredWidth: 160
                                        onClicked: {
                                            syncEditBuffer()
                                            editorPopup.open()
                                        }
                                    }
                                    */
                                }
                            }

                            // Main list area
                            StyledFrame {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                Rectangle { anchors.fill: parent; color: "#121b29"; opacity: 0.20 }

                                Flickable {
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    clip: true
                                    contentHeight: pidList.height

                                    Column {
                                        id: pidList
                                        width: parent.width
                                        spacing: 10

                                        Repeater {
                                            model: pidModel

                                            delegate: StyledFrame {
                                                width: pidList.width
                                                height: 78

                                                Rectangle { anchors.fill: parent; color: "#1c2a40"; opacity: 0.55 }

                                                RowLayout {
                                                    anchors.fill: parent
                                                    anchors.margins: 12
                                                    spacing: 12

                                                    // Left: mode label
                                                    Column {
                                                        Layout.preferredWidth: 110
                                                        spacing: 2
                                                        Text {
                                                            text: mode
                                                            color: "white"
                                                            font.pixelSize: 16
                                                            font.bold: true
                                                        }
                                                        Text {
                                                            text: "Flight Mode"
                                                            color: "#9aa7b7"
                                                            font.pixelSize: 12
                                                        }
                                                    }

                                                    // Right: gain cards (P/I/D)
                                                    RowLayout {
                                                        Layout.fillWidth: true
                                                        spacing: 10

                                                        // P
                                                        StyledFrame {
                                                            Layout.fillWidth: true
                                                            Layout.preferredHeight: 54
                                                            Rectangle { anchors.fill: parent; color: "#121b29"; opacity: 0.25 }

                                                            RowLayout {
                                                                anchors.fill: parent
                                                                anchors.margins: 10
                                                                spacing: 8
                                                                Text { text: "P"; color: "#9aa7b7"; font.bold: true; font.pixelSize: 12 }
                                                                Item { Layout.fillWidth: true }
                                                                Text { text: pidValuesPage.formatGain(pGain); color: "white"; font.bold: true; font.pixelSize: 16 }
                                                            }
                                                        }

                                                        // I
                                                        StyledFrame {
                                                            Layout.fillWidth: true
                                                            Layout.preferredHeight: 54
                                                            Rectangle { anchors.fill: parent; color: "#121b29"; opacity: 0.25 }

                                                            RowLayout {
                                                                anchors.fill: parent
                                                                anchors.margins: 10
                                                                spacing: 8
                                                                Text { text: "I"; color: "#9aa7b7"; font.bold: true; font.pixelSize: 12 }
                                                                Item { Layout.fillWidth: true }
                                                                Text { text: pidValuesPage.formatGain(iGain); color: "white"; font.bold: true; font.pixelSize: 16 }
                                                            }
                                                        }

                                                        // D
                                                        StyledFrame {
                                                            Layout.fillWidth: true
                                                            Layout.preferredHeight: 54
                                                            Rectangle { anchors.fill: parent; color: "#121b29"; opacity: 0.25 }

                                                            RowLayout {
                                                                anchors.fill: parent
                                                                anchors.margins: 10
                                                                spacing: 8
                                                                Text { text: "D"; color: "#9aa7b7"; font.bold: true; font.pixelSize: 12 }
                                                                Item { Layout.fillWidth: true }
                                                                Text { text: pidValuesPage.formatGain(dGain); color: "white"; font.bold: true; font.pixelSize: 16 }
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

                        // Popup editor (uses your styling components)
                        Popup {
                            id: editorPopup
                            modal: true
                            focus: true
                            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                            anchors.centerIn: Overlay.overlay
                            width: 640
                            padding: 0

                            background: Rectangle {
                                color: "#121b29"
                                radius: 10
                                border.width: 1
                                border.color: "#2c3e50"
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 12

                                Text {
                                    text: "Edit PID Values"
                                    color: "#87c0fa"
                                    font.pixelSize: 18
                                    font.bold: true
                                    Layout.fillWidth: true
                                }

                                Flickable {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    clip: true
                                    contentHeight: editorContent.implicitHeight

                                    ColumnLayout {
                                        id: editorContent
                                        width: parent.width
                                        spacing: 10

                                        Repeater {
                                            model: pidValuesPage.editBuffer

                                            delegate: ColumnLayout {
                                                required property var modelData
                                                required property int index

                                                Layout.fillWidth: true
                                                spacing: 6

                                                Text {
                                                    text: modelData.mode
                                                    color: "white"
                                                    font.pixelSize: 15
                                                    font.bold: true
                                                }

                                                RowLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 10

                                                    StyledTextField {
                                                        Layout.fillWidth: true
                                                        placeholderText: "P"
                                                        text: String(modelData.pGain)
                                                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                                                        validator: DoubleValidator { decimals: 4 }
                                                        onTextChanged: editBuffer[index].pGain = text
                                                    }

                                                    StyledTextField {
                                                        Layout.fillWidth: true
                                                        placeholderText: "I"
                                                        text: String(modelData.iGain)
                                                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                                                        validator: DoubleValidator { decimals: 4 }
                                                        onTextChanged: editBuffer[index].iGain = text
                                                    }

                                                    StyledTextField {
                                                        Layout.fillWidth: true
                                                        placeholderText: "D"
                                                        text: String(modelData.dGain)
                                                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                                                        validator: DoubleValidator { decimals: 4 }
                                                        onTextChanged: editBuffer[index].dGain = text
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    height: 1
                                                    color: "#2c3e50"
                                                    opacity: 0.6
                                                }
                                            }
                                        }
                                    }
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 10

                                    Item { Layout.fillWidth: true }

                                    StyledButton {
                                        text: "CANCEL"
                                        Layout.preferredWidth: 110
                                        onClicked: editorPopup.close()
                                    }

                                    StyledButton {
                                        text: "SAVE"
                                        Layout.preferredWidth: 110
                                        onClicked: applyEdits()
                                    }
                                }
                            }
                        }
                    }
                }

                // ACTION BAR
                RowLayout {
                    id: rowContentBottom

                    StyledButton {
                        text: "SAVE SETTINGS"
                        Layout.preferredWidth: 150
                        onClicked: {
                            if (mainStack.currentIndex === 0) {
                                // Example: collect enabled keys to persist later
                                var selected = []
                                for (var i = 0; i < dataModel.count; i++)
                                    if (dataModel.get(i).checked) selected.push(dataModel.get(i).key)
                                // TODO: send to C++ backend if you have an API
                                // settingsBridge.setDashboardFields(selected)
                            } else {
                                // Radio page: no-op (radio actions are live), or persist mode selection if you want
                            }
                        }
                    }

                    StyledButton {
                        text: "RESET"
                        Layout.preferredWidth: 100
                        onClicked: {
                            if (mainStack.currentIndex === 0) {
                                // TODO: reset to whatever your default set is (or reload from backend)
                            } else {
                                // radio page reset is ambiguous; keep no-op
                            }
                        }
                    }
                }
            }
        }
    }
}
