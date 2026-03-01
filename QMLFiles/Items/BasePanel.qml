import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: base

    //Visualization
    color: Theme.surface
    border.color: Theme.border
    border.width: Theme.strokePanel
    radius: Theme.radiusPanel

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
