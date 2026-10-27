import QtQuick 2.0
import Sailfish.Silica 1.0
Item {
    property color markerColor: "transparent"
    property color borderColor: "transparent"
    property string labelText: ""
    property bool smallMarker: false
    width: parent ? parent.width : 0
    height: Theme.itemSizeExtraSmall
    Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: smallMarker ? Theme.paddingMedium : Theme.paddingLarge
        height: width
        radius: width / 2
        color: markerColor
        border.color: borderColor
        border.width: borderColor === "transparent" ? 0 : 2
    }
    Label {
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingLarge + Theme.paddingMedium
        anchors.verticalCenter: parent.verticalCenter
        text: labelText
        color: Theme.primaryColor
    }
}
