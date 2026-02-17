import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: base

    //Visualization
    color: "#1F2937"
    border.color: "#2d3748"
    border.width: 4
    radius: 8

    //Sizing
    height: (parent.parent.height - 20)/2 - 10
    width: (parent.parent.width - 20)/4 - 5

    //Layout
    Layout.margins: 2
    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.minimumWidth: width
    Layout.minimumHeight: height

}
