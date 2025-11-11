import QtQuick

Rectangle {
    property string dataName
    property double dataValue
    property int sections       //How many boxes are together
    property int section_num    //Which box is this one

    height: parent.height/2
    width: (parent.width-18*sections)/sections
    x: (section_num-1) * (width+10)
    radius: 5
    border.color: "#2d3748"
    border.width: 2
    color: "#374151"

    Text {
        id: name

        text: dataName
        font.pixelSize: parent.width / sections / 13 + 4 * sections
        color: "#729AAF"

        anchors.centerIn: parent
        anchors.verticalCenterOffset: -10 + parent.height/20
    }

    Text {
        id: value

        anchors.top: name.bottom
        text: dataValue
        font.pixelSize: parent.width / sections / 13 + 4 * sections
        color: "#729AAF"

        anchors.horizontalCenter: parent.horizontalCenter;
    }

}
