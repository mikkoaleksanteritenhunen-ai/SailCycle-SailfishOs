import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/Database.js" as DB

CoverBackground {
    id: cover

    property var dashboard: ({})
    property var prediction: ({ available: false })

    property bool detailsEnabled: false
    property bool showCycleDay: true
    property bool showCurrentEnd: false
    property bool showNextStart: false
    property bool showNextEnd: false
    property bool showDaysRemaining: false
    property bool compactMode: false

    property string recordedCurrentEnd: ""
    property var currentEstimatedEnd: null

    function loadCover() {
        try {
            dashboard = DB.dashboardData()
            prediction = dashboard.prediction || ({ available: false })

            recordedCurrentEnd = dashboard.recordedCurrentEnd || ""
            currentEstimatedEnd = dashboard.currentEstimatedEnd || null

            detailsEnabled =
                    DB.setting("coverDetailsEnabled", "false") === "true"

            showCycleDay =
                    DB.setting("coverShowCycleDay", "true") === "true"

            showCurrentEnd =
                    DB.setting("coverShowCurrentEnd", "false") === "true"

            showNextStart =
                    DB.setting("coverShowNextStart", "false") === "true"

            showNextEnd =
                    DB.setting("coverShowNextEnd", "false") === "true"

            showDaysRemaining =
                    DB.setting("coverShowDaysRemaining", "false") === "true"

            compactMode =
                    DB.setting("coverCompactMode", "false") === "true"
        } catch (error) {
            console.log("Cover loading failed:", error)

            dashboard = ({})
            prediction = ({ available: false })
            detailsEnabled = false
        }
    }

    function formattedDate(value) {
        if (!value || value === undefined || value === null)
            return qsTr("Not available")

        if (typeof value === "string") {
            var parsed = DB.parseDate(value)

            if (!parsed)
                return qsTr("Not available")

            return parsed.toLocaleDateString(
                        Qt.locale(),
                        Locale.ShortFormat)
        }

        if (isNaN(value.getTime()))
            return qsTr("Not available")

        return value.toLocaleDateString(
                    Qt.locale(),
                    Locale.ShortFormat)
    }

    function currentEndDate() {
        if (recordedCurrentEnd)
            return DB.parseDate(recordedCurrentEnd)

        return currentEstimatedEnd
    }

    function currentEndLabel() {
        return recordedCurrentEnd
                ? qsTr("Recorded end")
                : qsTr("Estimated end")
    }

    Component.onCompleted: loadCover()

    onStatusChanged: {
        if (status === Cover.Active)
            loadCover()
    }

    Column {
        anchors.centerIn: parent
        width: parent.width - 2 * Theme.paddingLarge

        spacing: compactMode
                 ? Theme.paddingSmall
                 : Theme.paddingMedium

        Label {
            width: parent.width

            text: qsTr("Sail Cycle")
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeLarge

            horizontalAlignment: Text.AlignHCenter
        }

        Label {
            visible: !detailsEnabled
                     || !prediction.available

            width: parent.width

            text: prediction.available
                  ? qsTr("Private cycle tracker")
                  : qsTr("No cycle recorded")

            color: Theme.primaryColor
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }

        Label {
            visible: detailsEnabled
                     && prediction.available
                     && showCycleDay

            width: parent.width

            text: qsTr("Cycle day %1")
                    .arg(prediction.cycleDay)

            color: Theme.primaryColor

            font.pixelSize: compactMode
                            ? Theme.fontSizeMedium
                            : Theme.fontSizeLarge

            horizontalAlignment: Text.AlignHCenter
        }

        Label {
            visible: detailsEnabled
                     && prediction.available
                     && showCurrentEnd
                     && currentEndDate() !== null

            width: parent.width

            text: currentEndLabel()
                  + "\n"
                  + formattedDate(currentEndDate())

            color: recordedCurrentEnd
                   ? "#63C174"
                   : "#C7E86B"

            font.pixelSize: Theme.fontSizeSmall
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }

        Label {
            visible: detailsEnabled
                     && prediction.available
                     && showNextStart

            width: parent.width

            text: qsTr("Next estimate")
                  + "\n"
                  + formattedDate(prediction.next)

            color: "#A889A5"
            font.pixelSize: Theme.fontSizeSmall
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }

        Label {
            visible: detailsEnabled
                     && prediction.available
                     && showNextEnd

            width: parent.width

            text: qsTr("Estimated period end")
                  + "\n"
                  + formattedDate(prediction.end)

            color: "#C7E86B"
            font.pixelSize: Theme.fontSizeSmall
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }

        Label {
            visible: detailsEnabled
                     && prediction.available
                     && showDaysRemaining

            width: parent.width

            text: prediction.daysToNext >= 0
                  ? qsTr("About %1 days away")
                    .arg(prediction.daysToNext)
                  : qsTr("Estimated date has passed")

            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeExtraSmall
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
    }
}
