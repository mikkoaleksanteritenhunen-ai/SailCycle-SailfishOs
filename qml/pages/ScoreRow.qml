import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: scoreRow

    property string symbolText: ""
    property string scoreText: ""
    property string descriptionText: ""
    property int count: 0
    property int total: 0
    property color barColor: Theme.highlightColor

    readonly property int percent: total > 0
                                   ? Math.round(count * 100 / total)
                                   : 0

    width: parent ? parent.width : 0
    height: Theme.itemSizeSmall

    Label {
        id: symbolLabel

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: Theme.itemSizeExtraSmall

        text: scoreRow.symbolText
        color: scoreRow.barColor
        font.pixelSize: Theme.fontSizeMedium
        horizontalAlignment: Text.AlignHCenter
    }

    Label {
        id: scoreLabel

        anchors.left: symbolLabel.right
        anchors.verticalCenter: parent.verticalCenter
        width: Theme.paddingLarge

        text: scoreRow.scoreText
        color: Theme.primaryColor
        horizontalAlignment: Text.AlignHCenter
    }

    Label {
        id: resultLabel

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: Theme.itemSizeLarge

        text: qsTr("%1 d  %2%").arg(scoreRow.count).arg(scoreRow.percent)
        color: Theme.secondaryColor
        font.pixelSize: Theme.fontSizeExtraSmall
        horizontalAlignment: Text.AlignRight
    }

    Column {
        id: valueColumn

        anchors.left: scoreLabel.right
        anchors.leftMargin: Theme.paddingSmall
        anchors.right: resultLabel.left
        anchors.rightMargin: Theme.paddingMedium
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.paddingSmall

        Label {
            width: parent.width
            text: scoreRow.descriptionText
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeExtraSmall
            elide: Text.ElideRight
        }

        Item {
            width: parent.width
            height: Theme.paddingMedium

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: Theme.highlightBackgroundColor
                opacity: 0.25
            }

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.width * scoreRow.percent / 100
                radius: height / 2
                color: scoreRow.barColor
                visible: scoreRow.percent > 0
            }
        }
    }
}
