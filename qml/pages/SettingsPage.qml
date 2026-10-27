import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/Database.js" as DB

Page {
    id: page

    allowedOrientations: Orientation.All

    property string message: ""
    property bool loading: false

    function boolSetting(key, fallbackValue) {
        return DB.setting(key, fallbackValue ? "true" : "false") === "true"
    }

    function retentionIndex(value) {
        if (value === "6")
            return 0
        if (value === "12")
            return 1
        if (value === "24")
            return 2
        if (value === "36")
            return 3
        return 4
    }

    function retentionValue() {
        if (retentionBox.currentIndex === 0)
            return "6"
        if (retentionBox.currentIndex === 1)
            return "12"
        if (retentionBox.currentIndex === 2)
            return "24"
        if (retentionBox.currentIndex === 3)
            return "36"
        return "forever"
    }

    function loadSettings() {
        loading = true
        message = ""

        cycle.value = parseInt(DB.setting("cycleLength", "28"))
        period.value = parseInt(DB.setting("periodLength", "5"))
        predictions.checked = boolSetting("predictionsEnabled", true)

        var predictionMethod = DB.setting("predictionMethod", "recent3")
        method.currentIndex = predictionMethod === "manual"
                ? 0 : (predictionMethod === "all" ? 2 : 1)

        weekView.checked = boolSetting("weekViewEnabled", false)
        weekNumbers.checked = boolSetting("showWeekNumbers", false)
        currentEstimate.checked = boolSetting("showCurrentEstimate", true)
        nextEstimate.checked = boolSetting("showNextEstimate", true)
        endColors.checked = boolSetting("showEndColors", true)
        entryDots.checked = boolSetting("showEntryDots", true)
        legend.checked = boolSetting("showLegend", true)

        trackWellbeing.checked = boolSetting("trackWellbeing", true)
        trackPain.checked = boolSetting("trackPain", true)

        coverDetails.checked = boolSetting("coverDetailsEnabled", false)
        coverCycleDay.checked = boolSetting("coverShowCycleDay", true)
        coverCurrentEnd.checked = boolSetting("coverShowCurrentEnd", false)
        coverNextStart.checked = boolSetting("coverShowNextStart", false)
        coverNextEnd.checked = boolSetting("coverShowNextEnd", false)
        coverDaysRemaining.checked = boolSetting("coverShowDaysRemaining", false)
        coverCompact.checked = boolSetting("coverCompactMode", false)

        retentionBox.currentIndex = retentionIndex(
                    DB.setting("retentionMode", "forever"))

        loading = false
    }

    function saveSettings(showMessage) {
        DB.saveSetting("cycleLength", Math.round(cycle.value))
        DB.saveSetting("periodLength", Math.round(period.value))
        DB.saveSetting("predictionsEnabled", predictions.checked)
        DB.saveSetting("predictionMethod",
                       method.currentIndex === 0
                       ? "manual"
                       : (method.currentIndex === 2 ? "all" : "recent3"))

        DB.saveSetting("weekViewEnabled", weekView.checked)
        DB.saveSetting("showWeekNumbers", weekNumbers.checked)
        DB.saveSetting("showCurrentEstimate", currentEstimate.checked)
        DB.saveSetting("showNextEstimate", nextEstimate.checked)
        DB.saveSetting("showEndColors", endColors.checked)
        DB.saveSetting("showEntryDots", entryDots.checked)
        DB.saveSetting("showLegend", legend.checked)

        DB.saveSetting("trackWellbeing", trackWellbeing.checked)
        DB.saveSetting("trackPain", trackPain.checked)

        DB.saveSetting("coverDetailsEnabled", coverDetails.checked)
        DB.saveSetting("coverShowCycleDay", coverCycleDay.checked)
        DB.saveSetting("coverShowCurrentEnd", coverCurrentEnd.checked)
        DB.saveSetting("coverShowNextStart", coverNextStart.checked)
        DB.saveSetting("coverShowNextEnd", coverNextEnd.checked)
        DB.saveSetting("coverShowDaysRemaining", coverDaysRemaining.checked)
        DB.saveSetting("coverCompactMode", coverCompact.checked)

        DB.saveSetting("retentionMode", retentionValue())

        if (showMessage)
            message = qsTr("Settings saved")
    }

    function removeExpiredRecords() {
        // Save the currently visible retention choice before deletion.
        DB.saveSetting("retentionMode", retentionValue())
        var removed = DB.removeExpiredRecords()
        message = qsTr("Removed %1 records").arg(removed)
    }

    Component.onCompleted: loadSettings()

    SilicaFlickable {
        id: flickable

        anchors.fill: parent
        contentHeight: contentColumn.height + Theme.paddingLarge

        PullDownMenu {
            MenuItem {
                text: qsTr("Backup before updating")
                onClicked: pageStack.push(Qt.resolvedUrl("BackupPage.qml"))
            }
        }

        Column {
            id: contentColumn

            width: parent.width
            spacing: Theme.paddingSmall

            PageHeader {
                title: qsTr("Settings")
                description: qsTr("Predictions, calendar, privacy and data")
            }

            SectionHeader {
                text: qsTr("Cycle estimates")
            }

            Slider {
                id: cycle

                width: parent.width
                minimumValue: 20
                maximumValue: 40
                stepSize: 1
                label: qsTr("Your usual cycle length")
                valueText: qsTr("%1 days").arg(Math.round(value))
            }

            Label {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter

                text: qsTr("Counted from the first day of one period to the first day of the next. 28 days is only a starting estimate, not a target.")
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
            }

            Slider {
                id: period

                width: parent.width
                minimumValue: 2
                maximumValue: 10
                stepSize: 1
                label: qsTr("Your usual period length")
                valueText: qsTr("%1 days").arg(Math.round(value))
            }

            Label {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter

                text: qsTr("Used to estimate the current and next period range. Only information you record is shown as recorded information.")
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
            }

            TextSwitch {
                id: predictions

                text: qsTr("Enable predictions")
                description: checked
                             ? qsTr("Show estimated period dates")
                             : qsTr("Show recorded information only")
            }

            ComboBox {
                id: method

                visible: predictions.checked
                label: qsTr("Prediction method")

                menu: ContextMenu {
                    MenuItem { text: qsTr("Your usual cycle length") }
                    MenuItem { text: qsTr("Average of recent 3 cycles") }
                    MenuItem { text: qsTr("Average of all completed cycles") }
                }
            }

            SectionHeader {
                text: qsTr("Calendar")
            }

            TextSwitch {
                id: weekView
                text: qsTr("Use weekly calendar view")
            }

            TextSwitch {
                id: weekNumbers
                text: qsTr("Show ISO week numbers")
                description: qsTr("ISO weeks start on Monday")
            }

            TextSwitch {
                id: currentEstimate
                enabled: predictions.checked
                text: qsTr("Show current period estimate")
            }

            TextSwitch {
                id: nextEstimate
                enabled: predictions.checked
                text: qsTr("Show next period estimate")
            }

            TextSwitch {
                id: endColors
                text: qsTr("Show period end colours")
            }

            TextSwitch {
                id: entryDots
                text: qsTr("Show saved-entry dots")
            }

            TextSwitch {
                id: legend
                text: qsTr("Show calendar legend")
            }

            SectionHeader {
                text: qsTr("Daily check-in")
            }

            TextSwitch {
                id: trackWellbeing
                text: qsTr("Ask how I feel")
                description: qsTr("Optional 1-5 face scale in daily records")
            }

            TextSwitch {
                id: trackPain
                text: qsTr("Ask about pain")
                description: qsTr("Optional 0-5 pain scale in daily records")
            }

            SectionHeader {
                text: qsTr("App cover")
            }

            TextSwitch {
                id: coverDetails

                text: qsTr("Show cycle details on cover")
                description: checked
                             ? qsTr("Choose which details are visible below")
                             : qsTr("Show only the app name and private tracker text")
            }

            TextSwitch {
                id: coverCycleDay

                visible: coverDetails.checked
                text: qsTr("Show cycle day")
                description: qsTr("Example: Cycle day 8")
            }

            TextSwitch {
                id: coverCurrentEnd

                visible: coverDetails.checked
                text: qsTr("Show current period end")
                description: qsTr("Shows a recorded end date or the current estimate")
            }

            TextSwitch {
                id: coverNextStart

                visible: coverDetails.checked
                text: qsTr("Show next estimated start")
            }

            TextSwitch {
                id: coverNextEnd

                visible: coverDetails.checked
                text: qsTr("Show next estimated end")
            }

            TextSwitch {
                id: coverDaysRemaining

                visible: coverDetails.checked
                text: qsTr("Show estimated days remaining")
                description: qsTr("Example: About 20 days away")
            }

            TextSwitch {
                id: coverCompact

                visible: coverDetails.checked
                text: qsTr("Use compact cover layout")
                description: checked
                             ? qsTr("Use smaller text and tighter spacing")
                             : qsTr("Use the standard cover layout")
            }

            Label {
                visible: coverDetails.checked

                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter

                text: qsTr("Cover information can be visible on the Sailfish home screen. Disable cover details for maximum privacy.")
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.WordWrap
            }

            Label {
                visible: coverDetails.checked
                         && coverCycleDay.checked
                         && coverCurrentEnd.checked
                         && coverNextStart.checked
                         && coverNextEnd.checked
                         && coverDaysRemaining.checked

                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter

                text: qsTr("Many selected details may not fit on smaller covers. Enable compact layout or hide some details.")
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.WordWrap
            }

            SectionHeader {
                text: qsTr("Data retention")
            }

            ComboBox {
                id: retentionBox

                label: qsTr("Keep records")

                menu: ContextMenu {
                    MenuItem { text: qsTr("6 months") }
                    MenuItem { text: qsTr("1 year") }
                    MenuItem { text: qsTr("2 years") }
                    MenuItem { text: qsTr("3 years") }
                    MenuItem { text: qsTr("Forever") }
                }
            }

            Label {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter

                text: retentionBox.currentIndex === 4
                      ? qsTr("Records remain until you delete them or remove the app data.")
                      : qsTr("Records older than the selected period can be permanently removed. Create an update backup first if needed.")
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
            }

            Button {
                enabled: retentionBox.currentIndex !== 4
                anchors.horizontalCenter: parent.horizontalCenter

                text: qsTr("Remove expired records now")
                onClicked: expiredRemorse.execute(
                               qsTr("Removing expired records"),
                               removeExpiredRecords)
            }

            SectionHeader {
                text: qsTr("Update safety backup")
            }

            Label {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter

                text: qsTr("Create a backup only as a precaution before installing a new Sail Cycle version. Use it if the update fails or the new version cannot read the existing local data.")
                color: Theme.primaryColor
                wrapMode: Text.WordWrap
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter

                text: qsTr("Backup before updating")
                onClicked: pageStack.push(Qt.resolvedUrl("BackupPage.qml"))
            }

            SectionHeader {
                text: qsTr("Data management")
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter

                text: qsTr("Delete all cycle records")
                onClicked: deleteRemorse.execute(
                               qsTr("Deleting all cycle records"),
                               function() {
                                   DB.deleteAllRecords()
                                   message = qsTr("All cycle records deleted. Settings and backup files were kept.")
                               })
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter

                text: qsTr("Reset Sail Cycle")
                onClicked: resetRemorse.execute(
                               qsTr("Resetting all app data"),
                               function() {
                                   DB.resetAllData()
                                   loadSettings()
                                   message = qsTr("Sail Cycle reset. Backup files in Documents were not deleted.")
                               })
            }

            Label {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter

                text: qsTr("Files in Documents are never deleted by these actions. Remove old backup files manually with the file manager.")
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                preferredWidth: Theme.buttonWidthLarge

                text: qsTr("Save settings")
                onClicked: saveSettings(true)
            }

            Label {
                visible: message.length > 0
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter

                text: message
                color: Theme.highlightColor
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            Item {
                width: parent.width
                height: Theme.paddingLarge
            }
        }

        VerticalScrollDecorator {
            flickable: flickable
        }
    }

    RemorsePopup { id: expiredRemorse }
    RemorsePopup { id: deleteRemorse }
    RemorsePopup { id: resetRemorse }
}
