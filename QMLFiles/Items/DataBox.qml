import QtQuick

Rectangle {
    property string dataName
    property double dataValue
    property int sections       //How many boxes are together
    property int section_num    //Which box is this one

    function formatDataValue(value) {
        const numericValue = Number(value)
        if (!Number.isFinite(numericValue)) {
            return String(value)
        }
        return numericValue.toFixed(2)
    }

    height: 56
    width: (parent.width-18*sections)/sections
    x: (section_num-1) * (width+10)
    radius: Theme.radiusCard
    border.color: Theme.border
    border.width: Theme.strokeControl
    color: Theme.surfaceElevated

    Text {
        id: name

        text: dataName
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontMetricLabel
        color: Theme.textTertiary

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 6
    }

    Text {
        id: value

        anchors.top: name.bottom
        anchors.topMargin: 2
        text: formatDataValue(dataValue)
        font.family: Theme.monoFamily
        font.pixelSize: Theme.fontMetricValue
        color: Theme.textPrimary

        anchors.horizontalCenter: parent.horizontalCenter;
    }

}
