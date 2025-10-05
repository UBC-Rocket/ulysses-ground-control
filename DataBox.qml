import QtQuick

Rectangle {
    property string dataName
    property double dataValue
    property int sections       //How many boxes are together
    property int section_num    //Which box is this one
    // property bool row: true

    height: 50
    width: (parent.width-18*sections)/sections
    x: (section_num-1) * (width+10)
    radius: 5
    border.color: "#2d3748"
    border.width: 2

    color: "#374151"


    Text {

        id: name
        text: dataName
        font.pixelSize: 14
        color: "#729AAF"

        anchors.centerIn: parent
        anchors.verticalCenterOffset: -10
    }
    Text {
        id: value
        anchors.top: name.bottom
        text: dataValue
        font.pixelSize: 14
        color: "#729AAF"

        anchors.horizontalCenter: parent.horizontalCenter;
    }
}
