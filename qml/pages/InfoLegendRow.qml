import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    property color markerColor: "transparent"
    property string labelText: ""

    width: parent ? parent.width : 0
    height: Theme.itemSizeExtraSmall

    Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: Theme.paddingLarge
        height: width
        radius: width / 2
        color: markerColor
    }

    Label {
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingLarge + Theme.paddingMedium
        anchors.verticalCenter: parent.verticalCenter
        text: labelText
        color: Theme.primaryColor
    }
}
