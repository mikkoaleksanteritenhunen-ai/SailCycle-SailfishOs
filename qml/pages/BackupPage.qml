import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/Database.js" as DB

Page {
    id: page
    property string message: ""

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height + Theme.paddingLarge
        Column {
            id: content
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader { title: qsTr("Update safety backup"); description: qsTr("Before installing a new version") }

            Label {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("This backup is a precaution for a Sail Cycle version update. Restore it only if an update fails, local records disappear, or the new version cannot read the existing database.")
                color: Theme.primaryColor
                wrapMode: Text.WordWrap
            }

            DetailItem { label: qsTr("Folder"); value: qsTr("Documents") }
            DetailItem { label: qsTr("File"); value: qsTr("SailCycle-backup.json") }
            DetailItem { label: qsTr("Full path"); value: fileHelper.backupPath() }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                preferredWidth: Theme.buttonWidthLarge
                text: qsTr("Create update backup")
                onClicked: message = fileHelper.writeBackup(JSON.stringify(DB.backupObject(), null, 2))
                                     ? qsTr("Update backup created in Documents")
                                     : qsTr("Backup creation failed")
            }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                preferredWidth: Theme.buttonWidthLarge
                text: qsTr("Restore after failed update")
                onClicked: restoreRemorse.execute(qsTr("Replacing local data from backup"), function() {
                    try {
                        var text = fileHelper.readBackup()
                        if (!text) throw new Error("File not found")
                        DB.importBackup(text)
                        message = qsTr("Update backup restored")
                    } catch (error) {
                        message = qsTr("Restore failed: %1").arg(error.message)
                    }
                })
            }

            Label { width: parent.width; text: message; color: Theme.highlightColor; horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap }
            Label {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Version 0.1 backup files are not encrypted. Keep the file private. Creating a new backup replaces the previous SailCycle-backup.json file.")
                color: Theme.highlightColor
                wrapMode: Text.WordWrap
            }
        }
        VerticalScrollDecorator {}
    }
    RemorsePopup { id: restoreRemorse }
}
