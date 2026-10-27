import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/Database.js" as DB

Page {
    id: page
    allowedOrientations: Orientation.All

    property date today: new Date()
    property date calendarDate: new Date()
    property bool weekView: false
    property bool weekNumbers: false
    property bool showEndColors: true
    property bool showEntryDots: true
    property bool showLegend: true
    property var prediction: ({ available: false })
    property var recordedDays: ({})
    property var currentEstimatedDays: ({})
    property var nextEstimatedDays: ({})
    property var recordedEndDays: ({})
    property var estimatedEndDays: ({})
    property var savedEntries: ({})
    property var currentEstimatedEnd: null
    property string recordedCurrentEnd: ""
    property int recordCount: 0

    function monday(value) {
        return DB.addDays(value, value.getDay() === 0 ? -6 : 1 - value.getDay())
    }
    function isoWeek(value) {
        var d = new Date(value.getFullYear(), value.getMonth(), value.getDate())
        var w = d.getDay() === 0 ? 7 : d.getDay()
        d.setDate(d.getDate() + 4 - w)
        return Math.ceil((((d - new Date(d.getFullYear(), 0, 1)) / 86400000) + 1) / 7)
    }
    function monthOffset() {
        var d = new Date(calendarDate.getFullYear(), calendarDate.getMonth(), 1).getDay()
        return d === 0 ? 6 : d - 1
    }
    function cellDate(index) {
        if (weekView) return DB.addDays(monday(calendarDate), index)
        var day = index - monthOffset() + 1
        var max = new Date(calendarDate.getFullYear(), calendarDate.getMonth() + 1, 0).getDate()
        return day < 1 || day > max ? null : new Date(calendarDate.getFullYear(), calendarDate.getMonth(), day)
    }
    function calendarTitle() {
        if (!weekView)
            return Qt.formatDate(new Date(calendarDate.getFullYear(), calendarDate.getMonth(), 1), "MMMM yyyy")
        var first = monday(calendarDate)
        var last = DB.addDays(first, 6)
        var range = first.toLocaleDateString(Qt.locale(), Locale.ShortFormat)
                + " - " + last.toLocaleDateString(Qt.locale(), Locale.ShortFormat)
        return weekNumbers ? qsTr("Week %1: %2").arg(isoWeek(first)).arg(range) : range
    }
    function predictionMethodText() {
        if (!prediction.available) return ""
        if (prediction.basis === "Recent cycle average")
            return qsTr("Based on recent completed cycles")
        if (prediction.basis === "All-cycle average")
            return qsTr("Based on all completed cycles")
        return qsTr("Based on your usual cycle length")
    }
    function reload() {
        var data = DB.dashboardData()
        prediction = data.prediction
        weekView = data.weekViewEnabled
        weekNumbers = data.showWeekNumbers
        showEndColors = data.showEndColors
        showEntryDots = data.showEntryDots
        showLegend = data.showLegend
        recordedDays = data.recordedDays
        currentEstimatedDays = data.currentEstimatedDays
        nextEstimatedDays = data.nextEstimatedDays
        recordedEndDays = data.recordedEndDays
        estimatedEndDays = data.estimatedEndDays
        savedEntries = data.savedEntries
        currentEstimatedEnd = data.currentEstimatedEnd
        recordedCurrentEnd = data.recordedCurrentEnd
        recordCount = data.recordCount
    }

    Component.onCompleted: reload()
    onStatusChanged: if (status === PageStatus.Active) reload()

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height + Theme.paddingLarge

        PullDownMenu {
            MenuItem { text: qsTr("Add record"); onClicked: pageStack.push(Qt.resolvedUrl("AddRecordPage.qml")) }
            MenuItem { text: qsTr("Cycle history"); onClicked: pageStack.push(Qt.resolvedUrl("CycleHistoryPage.qml")) }
            MenuItem { text: qsTr("Statistics"); onClicked: pageStack.push(Qt.resolvedUrl("StatisticsPage.qml")) }
            MenuItem { text: qsTr("Settings"); onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml")) }
            MenuItem { text: qsTr("Cycle information"); onClicked: pageStack.push(Qt.resolvedUrl("MenstruationInfoPage.qml")) }
            MenuItem { text: qsTr("About Sail Cycle"); onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml")) }
        }

        Column {
            id: content
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader { title: qsTr("Sail Cycle"); description: qsTr("Your private cycle tracker") }

            SectionHeader { text: qsTr("Current cycle") }
            Label {
                width: parent.width
                text: prediction.available ? qsTr("Cycle day %1").arg(prediction.cycleDay) : qsTr("No cycle recorded")
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeExtraLarge
                horizontalAlignment: Text.AlignHCenter
            }
            Label {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                text: prediction.available
                      ? qsTr("Started %1").arg(prediction.latest.toLocaleDateString(Qt.locale(), Locale.LongFormat))
                      : qsTr("Record a period start to begin tracking.")
                color: Theme.secondaryColor
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
            DetailItem {
                visible: prediction.available
                label: recordedCurrentEnd ? qsTr("Recorded bleeding end") : qsTr("Estimated bleeding end")
                value: recordedCurrentEnd
                       ? DB.parseDate(recordedCurrentEnd).toLocaleDateString(Qt.locale(), Locale.LongFormat)
                       : (currentEstimatedEnd ? currentEstimatedEnd.toLocaleDateString(Qt.locale(), Locale.LongFormat) : qsTr("Not available"))
            }
            Label {
                visible: prediction.available && !recordedCurrentEnd
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Based on your usual period length of %1 days. Record the actual end date when known.").arg(prediction.periodLength)
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.WordWrap
            }

            SectionHeader { text: qsTr("Next cycle") }
            BackgroundItem {
                width: parent.width
                height: nextCard.height + 2 * Theme.paddingMedium
                enabled: prediction.available
                Column {
                    id: nextCard
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: Theme.horizontalPageMargin
                    anchors.rightMargin: Theme.horizontalPageMargin
                    spacing: Theme.paddingSmall
                    Label { text: qsTr("Estimated start"); color: Theme.secondaryColor }
                    Label {
                        text: prediction.available ? prediction.next.toLocaleDateString(Qt.locale(), Locale.LongFormat) : qsTr("Not available")
                        color: Theme.highlightColor
                        font.pixelSize: Theme.fontSizeLarge
                    }
                    Label {
                        text: prediction.available
                              ? qsTr("Estimated period: %1 - %2")
                                .arg(prediction.next.toLocaleDateString(Qt.locale(), Locale.ShortFormat))
                                .arg(prediction.end.toLocaleDateString(Qt.locale(), Locale.ShortFormat))
                              : ""
                        color: Theme.primaryColor
                    }
                    Label { text: prediction.available ? predictionMethodText() : ""; color: Theme.secondaryColor }
                }
            }

            SectionHeader { text: qsTr("Calendar") }
            Item {
                width: parent.width
                height: Theme.itemSizeSmall
                IconButton {
                    anchors.left: parent.left
                    icon.source: "image://theme/icon-m-left"
                    onClicked: calendarDate = weekView ? DB.addDays(calendarDate, -7)
                                                       : new Date(calendarDate.getFullYear(), calendarDate.getMonth() - 1, 1)
                }
                Label { anchors.centerIn: parent; text: calendarTitle(); color: Theme.highlightColor; font.pixelSize: Theme.fontSizeLarge }
                IconButton {
                    anchors.right: parent.right
                    icon.source: "image://theme/icon-m-right"
                    onClicked: calendarDate = weekView ? DB.addDays(calendarDate, 7)
                                                       : new Date(calendarDate.getFullYear(), calendarDate.getMonth() + 1, 1)
                }
            }
            Button { anchors.horizontalCenter: parent.horizontalCenter; text: qsTr("Today"); onClicked: calendarDate = new Date() }
            Row {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                Label { visible: weekNumbers; width: Theme.itemSizeExtraSmall; text: qsTr("Wk"); color: Theme.secondaryColor; horizontalAlignment: Text.AlignHCenter }
                Row {
                    width: parent.width - (weekNumbers ? Theme.itemSizeExtraSmall : 0)
                    Repeater {
                        model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                        Label { width: parent.width / 7; text: modelData; color: Theme.secondaryColor; horizontalAlignment: Text.AlignHCenter }
                    }
                }
            }
            Row {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                Column {
                    visible: weekNumbers
                    width: Theme.itemSizeExtraSmall
                    Repeater {
                        model: weekView ? 1 : 6
                        Item {
                            width: Theme.itemSizeExtraSmall
                            height: weekView ? Theme.itemSizeLarge : Theme.itemSizeSmall
                            Label {
                                anchors.centerIn: parent
                                text: weekView ? isoWeek(monday(calendarDate))
                                               : isoWeek(DB.addDays(new Date(calendarDate.getFullYear(), calendarDate.getMonth(), 1), -monthOffset() + index * 7))
                                color: Theme.secondaryHighlightColor
                                font.pixelSize: Theme.fontSizeExtraSmall
                            }
                        }
                    }
                }
                Grid {
                    width: parent.width - (weekNumbers ? Theme.itemSizeExtraSmall : 0)
                    columns: 7
                    Repeater {
                        model: weekView ? 7 : 42
                        Item {
                            width: (content.width - 2 * Theme.horizontalPageMargin - (weekNumbers ? Theme.itemSizeExtraSmall : 0)) / 7
                            height: weekView ? Theme.itemSizeLarge : Theme.itemSizeSmall
                            property var value: cellDate(index)
                            property bool valid: value !== null && value !== undefined && !isNaN(value.getTime())
                            property string key: valid ? DB.isoDate(value) : ""
                            property bool todayCell: key === DB.isoDate(today)
                            Rectangle {
                                anchors.centerIn: parent
                                width: Theme.itemSizeExtraSmall
                                height: width
                                radius: width / 2
                                color: showEndColors && recordedEndDays[parent.key] ? "#63C174"
                                       : (showEndColors && estimatedEndDays[parent.key] ? "#C7E86B"
                                       : (recordedDays[parent.key] ? "#E85D75"
                                       : (currentEstimatedDays[parent.key] ? "#EFA0AD"
                                       : (nextEstimatedDays[parent.key] ? "#A889A5" : "transparent"))))
                                border.color: parent.todayCell ? Theme.highlightColor : "transparent"
                                border.width: parent.todayCell ? 2 : 0
                            }
                            Label {
                                anchors.centerIn: parent
                                text: parent.valid ? String(parent.value.getDate()) : ""
                                color: (recordedEndDays[parent.key] || estimatedEndDays[parent.key]) ? "#172015" : Theme.primaryColor
                            }
                            Rectangle {
                                visible: showEntryDots && savedEntries[parent.key] === true
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottom: parent.bottom
                                width: Theme.paddingMedium
                                height: width
                                radius: width / 2
                                color: "white"
                            }
                            MouseArea {
                                anchors.fill: parent
                                enabled: parent.valid
                                onClicked: pageStack.push(Qt.resolvedUrl("AddRecordPage.qml"), { initialDate: parent.value })
                            }
                        }
                    }
                }
            }

            SectionHeader { visible: showLegend; text: qsTr("Calendar legend") }
            Column {
                visible: showLegend
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.paddingSmall
                LegendRow { markerColor: "#E85D75"; labelText: qsTr("Recorded period day") }
                LegendRow { markerColor: "#EFA0AD"; labelText: qsTr("Current period estimate") }
                LegendRow { markerColor: "#A889A5"; labelText: qsTr("Next estimated period") }
                LegendRow { markerColor: "#63C174"; labelText: qsTr("Recorded period end") }
                LegendRow { markerColor: "#C7E86B"; labelText: qsTr("Estimated period end") }
                LegendRow { markerColor: "transparent"; borderColor: Theme.highlightColor; labelText: qsTr("Today") }
                LegendRow { markerColor: "white"; smallMarker: true; labelText: qsTr("Saved entry") }
            }

            SectionHeader { text: qsTr("Today") }
            DetailItem {
                label: savedEntries[DB.isoDate(today)] ? qsTr("Entry recorded") : qsTr("No entry recorded")
                value: today.toLocaleDateString(Qt.locale(), Locale.ShortFormat)
            }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                preferredWidth: Theme.buttonWidthLarge
                text: savedEntries[DB.isoDate(today)] ? qsTr("Edit today's entry") : qsTr("Add today's entry")
                onClicked: pageStack.push(Qt.resolvedUrl("AddRecordPage.qml"), { initialDate: today })
            }
            Button {
                visible: prediction.available && !recordedCurrentEnd
                anchors.horizontalCenter: parent.horizontalCenter
                preferredWidth: Theme.buttonWidthLarge
                text: qsTr("Record period end")
                onClicked: pageStack.push(Qt.resolvedUrl("AddRecordPage.qml"), { initialDate: today })
            }
            DetailItem { label: qsTr("Your usual cycle"); value: qsTr("%1 days").arg(prediction.cycleLength || 28) }
            DetailItem { label: qsTr("Your usual period"); value: qsTr("%1 days").arg(prediction.periodLength || 5) }
            DetailItem { label: qsTr("Saved records"); value: String(recordCount) }
            Item { width: parent.width; height: Theme.paddingLarge }
        }
        VerticalScrollDecorator {}
    }

}
