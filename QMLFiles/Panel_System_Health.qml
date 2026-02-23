import QtQuick
import QtQuick.Layouts
import "Items"

BasePanel {
    id: panel_System_Health

    function sensorOk(name) {
        switch (name) {
        case "ACCEL": return sensorData.accelOk
        case "GYRO": return sensorData.gyroOk
        case "BARO 1": return sensorData.baro1Ok
        case "BARO 2": return sensorData.baro2Ok
        case "GPS": return sensorData.gpsConnected
        default: return false
        }
    }

    BaseHeader {
        id: header
        headerText: "System Health"
    }

    // ── Section 1: Sensor health badges ────────────────────────────────────

    Text {
        id: sensorLabel
        anchors {
            top: header.bottom
            left: parent.left
            leftMargin: 15
            topMargin: 6
        }
        text: "Sensor Status"
        font.family: Theme.fontFamily
        font.pixelSize: 15
        color: Theme.textSecondary
    }

    Row {
        id: sensorRow
        anchors {
            top: sensorLabel.bottom
            left: parent.left
            right: parent.right
            leftMargin: 15
            rightMargin: 15
            topMargin: 8
        }
        spacing: 8

        Repeater {
            id: sensorRepeater
            model: ["ACCEL", "GYRO", "BARO 1", "BARO 2", "GPS"]

            delegate: Column {
                spacing: 4
                width: (sensorRow.width - sensorRow.spacing * 4) / 5

                Rectangle {
                    width: parent.width
                    height: 28
                    radius: Theme.radiusControl
                    color: panel_System_Health.sensorOk(modelData) ? Theme.success : Theme.danger

                    Text {
                        anchors.centerIn: parent
                        text: panel_System_Health.sensorOk(modelData) ? "OK" : "FAIL"
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        font.bold: true
                        color: Theme.textPrimary
                    }
                }

                Text {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontCaption
                    color: Theme.textTertiary
                }
            }
        }
    }

    // ── Section 2: System stats ─────────────────────────────────────────────

    Text {
        id: statsLabel
        anchors {
            top: sensorRow.bottom
            left: parent.left
            leftMargin: 15
            topMargin: 14
        }
        text: "System Stats"
        font.family: Theme.fontFamily
        font.pixelSize: 15
        color: Theme.textSecondary
    }

    DataBoxList {
        id: statsBoxes
        anchors {
            top: statsLabel.bottom
            left: parent.left
            right: parent.right
            leftMargin: 15
            topMargin: 8
        }

        size: 2
        boxHeight: 56
        dataNames: ["UPTIME (s)", "CMD RX"]
        dataValues: [
            sensorData.uptimeMs / 1000,
            sensorData.cmdRxCount
        ]
    }
}
