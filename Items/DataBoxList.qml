import QtQuick

Rectangle {
    anchors.left: parent.left

    property int size
    property int boxHeight: 50
    property list<string> dataNames
    property list<double> dataValues

    color: "transparent"

    Repeater {
        model: size

        DataBox {
            required property int index
            dataName: dataNames[index]
            dataValue: dataValues[index]
            sections: size
            section_num: index+1
            height: boxHeight
        }
    }

}
