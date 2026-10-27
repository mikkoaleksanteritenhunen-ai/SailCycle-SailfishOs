import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/Database.js" as DB

Page {
    id: page
    allowedOrientations: Orientation.All
    property date initialDate: new Date()
    property int editingId: -1
    property bool loading: true
    property int wellbeingScore: 0
    property int painScore: -1
    property string validationMessage: ""
    property bool trackWellbeing: true
    property bool trackPain: true
    property int energyScore: 0
    property int sleepQuality: 0
    property int painImpact: 0
    property int bleedingImpact: 0
    property int outsideBleeding: 0
    property int largeClots: -1
    property int sleepImpact: 0
    property string painLocations: ""

    function observations() {
        var values = []
        if (cramps.checked) values.push("Cramps")
        if (headache.checked) values.push("Headache")
        if (fatigue.checked) values.push("Fatigue")
        if (bloating.checked) values.push("Bloating")
        if (sleep.checked) values.push("Sleep changes")
        if (stress.checked) values.push("Stress")
        return values.join(",")
    }
    function loadRecord() {
        loading = true
        trackWellbeing = DB.setting("trackWellbeing", "true") === "true"
        trackPain = DB.setting("trackPain", "true") === "true"
        var record = DB.recordForDate(DB.isoDate(initialDate))
        if (record) {
            editingId = record.id
            typeBox.currentIndex = record.recordType === "periodStart" ? 0 : (record.recordType === "periodEnd" ? 1 : 2)
            flowBox.currentIndex = record.flow === "spotting" ? 1 : (record.flow === "light" ? 2 : (record.flow === "medium" ? 3 : (record.flow === "heavy" ? 4 : 0)))
            notes.text = record.notes || ""
            wellbeingScore = record.wellbeingScore === null || record.wellbeingScore === undefined ? 0 : parseInt(record.wellbeingScore)
            painScore = record.painScore === null || record.painScore === undefined ? -1 : parseInt(record.painScore)
            var extra = {}; try { extra = JSON.parse(record.extraData || "{}") } catch (error) {}
            energyScore = extra.energyScore || 0; sleepQuality = extra.sleepQuality || 0; painImpact = extra.painImpact || 0; bleedingImpact = extra.bleedingImpact || 0; outsideBleeding = extra.outsideBleeding || 0; largeClots = extra.largeClots === undefined ? -1 : extra.largeClots; sleepImpact = extra.sleepImpact || 0; painLocations = extra.painLocations || ""
            var saved = (record.observations || "").split(",")
            cramps.checked = saved.indexOf("Cramps") >= 0
            headache.checked = saved.indexOf("Headache") >= 0
            fatigue.checked = saved.indexOf("Fatigue") >= 0
            bloating.checked = saved.indexOf("Bloating") >= 0
            sleep.checked = saved.indexOf("Sleep changes") >= 0
            stress.checked = saved.indexOf("Stress") >= 0
        } else {
            editingId = -1
            typeBox.currentIndex = 0
            flowBox.currentIndex = 0
            notes.text = ""
            wellbeingScore = 0
            painScore = -1
            energyScore=0; sleepQuality=0; painImpact=0; bleedingImpact=0; outsideBleeding=0; largeClots=-1; sleepImpact=0; painLocations=""
            cramps.checked = false
            headache.checked = false
            fatigue.checked = false
            bloating.checked = false
            sleep.checked = false
            stress.checked = false
        }
        loading = false
    }
    function deleteOrDiscard() {
        if (editingId >= 0) {
            deleteRemorse.execute(qsTr("Deleting record"), function() {
                DB.deleteRecord(editingId)
                pageStack.pop()
            })
        } else {
            pageStack.pop()
        }
    }

    function saveRecord() {
        var typeValue = typeBox.currentIndex === 0 ? "periodStart" : (typeBox.currentIndex === 1 ? "periodEnd" : "daily")
        var flowValue = flowBox.currentIndex === 0 ? "none" : (flowBox.currentIndex === 1 ? "spotting" : (flowBox.currentIndex === 2 ? "light" : (flowBox.currentIndex === 3 ? "medium" : "heavy")))
        var validation = DB.validateRecord(editingId, DB.isoDate(initialDate), typeValue, flowValue, notes.text)
        if (!validation.valid) {
            validationMessage = validation.message
            return
        }
        DB.saveRecord(editingId, DB.isoDate(initialDate), typeValue, flowValue,
                      observations(), notes.text, wellbeingScore, painScore, JSON.stringify({energyScore:energyScore,sleepQuality:sleepQuality,painImpact:painImpact,bleedingImpact:bleedingImpact,outsideBleeding:outsideBleeding,largeClots:largeClots,sleepImpact:sleepImpact,painLocations:painLocations}))
        pageStack.pop()
    }

    Component.onCompleted: loadRecord()

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height + Theme.paddingLarge

        PushUpMenu {
            MenuItem {
                text: qsTr("Save record")
                onClicked: saveRecord()
            }
            MenuItem {
                text: editingId >= 0 ? qsTr("Delete record") : qsTr("Discard without saving")
                onClicked: deleteOrDiscard()
            }
        }
        Column {
            id: content
            width: parent.width

            PageHeader {
                title: editingId >= 0 ? qsTr("Edit record") : qsTr("Add record")
                description: initialDate.toLocaleDateString(Qt.locale(), Locale.LongFormat)
            }
            ValueButton {
                label: qsTr("Selected date")
                value: initialDate.toLocaleDateString(Qt.locale(), Locale.LongFormat)
                onClicked: picker.visible = !picker.visible
            }
            DatePicker {
                id: picker
                visible: false
                width: parent.width
                date: initialDate
                onDateChanged: if (!loading && DB.isoDate(date) !== DB.isoDate(initialDate)) { initialDate = date; loadRecord() }
            }
            Label {
                visible: validationMessage.length > 0
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                text: validationMessage
                color: Theme.highlightColor
                wrapMode: Text.WordWrap
            }

            ComboBox {
                id: typeBox
                label: qsTr("Record type")
                menu: ContextMenu {
                    MenuItem { text: qsTr("Period started") }
                    MenuItem { text: qsTr("Period ended") }
                    MenuItem { text: qsTr("Daily entry") }
                }
            }
            ComboBox {
                id: flowBox
                label: qsTr("Flow")
                menu: ContextMenu {
                    MenuItem { text: qsTr("None") }
                    MenuItem { text: qsTr("Spotting") }
                    MenuItem { text: qsTr("Light") }
                    MenuItem { text: qsTr("Medium") }
                    MenuItem { text: qsTr("Heavy") }
                }
            }

            SectionHeader { visible: trackWellbeing; text: qsTr("How do you feel now?") }
            Label {
                visible: trackWellbeing
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                text: wellbeingScore > 0 ? qsTr("Selected: %1 of 5").arg(wellbeingScore) : qsTr("Optional: choose one face")
                color: wellbeingScore > 0 ? Theme.highlightColor : Theme.secondaryColor
                horizontalAlignment: Text.AlignHCenter
            }
            Row {
                visible: trackWellbeing
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                Repeater {
                    model: ["☹", "🙁", "😐", "🙂", "😊"]
                    BackgroundItem {
                        width: parent.width / 5
                        height: Theme.itemSizeLarge
                        highlighted: wellbeingScore === index + 1
                        Column {
                            anchors.centerIn: parent
                            Label { anchors.horizontalCenter: parent.horizontalCenter; text: modelData; font.pixelSize: Theme.fontSizeLarge; color: wellbeingScore === index + 1 ? Theme.highlightColor : Theme.primaryColor }
                            Label { anchors.horizontalCenter: parent.horizontalCenter; text: String(index + 1); font.pixelSize: Theme.fontSizeExtraSmall; color: Theme.secondaryColor }
                        }
                        onClicked: wellbeingScore = wellbeingScore === index + 1 ? 0 : index + 1
                    }
                }
            }
            Label {
                visible: trackWellbeing
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("1 = very low, 3 = okay, 5 = very good")
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                horizontalAlignment: Text.AlignHCenter
            }

            SectionHeader { visible: trackPain; text: qsTr("Pain now") }
            Label {
                visible: trackPain
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                text: painScore >= 0 ? qsTr("Selected: %1 of 5").arg(painScore) : qsTr("Optional: choose pain level")
                color: painScore >= 0 ? Theme.highlightColor : Theme.secondaryColor
                horizontalAlignment: Text.AlignHCenter
            }
            Row {
                visible: trackPain
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                Repeater {
                    model: 6
                    BackgroundItem {
                        width: parent.width / 6
                        height: Theme.itemSizeMedium
                        highlighted: painScore === index
                        Column {
                            anchors.centerIn: parent
                            Label { anchors.horizontalCenter: parent.horizontalCenter; text: index === 0 ? "○" : "●"; color: index >= 4 ? "#E85D75" : (index >= 2 ? "#E8C75A" : Theme.highlightColor) }
                            Label { anchors.horizontalCenter: parent.horizontalCenter; text: String(index); font.pixelSize: Theme.fontSizeExtraSmall; color: Theme.secondaryColor }
                        }
                        onClicked: painScore = painScore === index ? -1 : index
                    }
                }
            }
            Label {
                visible: trackPain
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("0 = no pain, 3 = moderate, 5 = very strong")
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                horizontalAlignment: Text.AlignHCenter
            }

            SectionHeader { text: qsTr("Daily details") }
            ComboBox { id: energyBox; label: qsTr("Energy today"); currentIndex: energyScore; onCurrentIndexChanged: energyScore=currentIndex; menu: ContextMenu { MenuItem{text:qsTr("Not answered")} MenuItem{text:qsTr("1 Very low")} MenuItem{text:qsTr("2 Low")} MenuItem{text:qsTr("3 Okay")} MenuItem{text:qsTr("4 Good")} MenuItem{text:qsTr("5 High")} } }
            ComboBox { id: sleepBox; label: qsTr("Sleep quality"); currentIndex: sleepQuality; onCurrentIndexChanged: sleepQuality=currentIndex; menu: ContextMenu { MenuItem{text:qsTr("Not answered")} MenuItem{text:qsTr("1 Very poor")} MenuItem{text:qsTr("2 Poor")} MenuItem{text:qsTr("3 Okay")} MenuItem{text:qsTr("4 Good")} MenuItem{text:qsTr("5 Very good")} } }
            ComboBox { label: qsTr("Pain affected normal activities"); currentIndex:painImpact; onCurrentIndexChanged:painImpact=currentIndex; menu:ContextMenu{MenuItem{text:qsTr("Not answered")}MenuItem{text:qsTr("Not at all")}MenuItem{text:qsTr("A little")}MenuItem{text:qsTr("Moderately")}MenuItem{text:qsTr("A lot")}MenuItem{text:qsTr("Unable to do normal activities")}} }
            TextField { width:parent.width; label:qsTr("Pain locations"); placeholderText:qsTr("Example: cramps, lower back, head"); text:painLocations; onTextChanged:painLocations=text }
            ComboBox { label:qsTr("Bleeding affected normal activities"); currentIndex:bleedingImpact; onCurrentIndexChanged:bleedingImpact=currentIndex; menu:ContextMenu{MenuItem{text:qsTr("Not answered")}MenuItem{text:qsTr("Not at all")}MenuItem{text:qsTr("A little")}MenuItem{text:qsTr("Moderately")}MenuItem{text:qsTr("A lot")}MenuItem{text:qsTr("Unable to do normal activities")}} }
            ComboBox { label:qsTr("Bleeding outside expected period"); currentIndex:outsideBleeding; onCurrentIndexChanged:outsideBleeding=currentIndex; menu:ContextMenu{MenuItem{text:qsTr("Not answered")}MenuItem{text:qsTr("No")}MenuItem{text:qsTr("Spotting")}MenuItem{text:qsTr("Bleeding")}} }
            ComboBox { label:qsTr("Large blood clots"); currentIndex:largeClots+1; onCurrentIndexChanged:largeClots=currentIndex-1; menu:ContextMenu{MenuItem{text:qsTr("Not answered")}MenuItem{text:qsTr("No")}MenuItem{text:qsTr("Yes")}MenuItem{text:qsTr("Not sure")}} }
            ComboBox { label:qsTr("Symptoms disturbed sleep"); currentIndex:sleepImpact; onCurrentIndexChanged:sleepImpact=currentIndex; menu:ContextMenu{MenuItem{text:qsTr("Not answered")}MenuItem{text:qsTr("No")}MenuItem{text:qsTr("A little")}MenuItem{text:qsTr("A lot")}} }

            SectionHeader { text: qsTr("Observations") }
            TextSwitch { id: cramps; text: qsTr("Cramps") }
            TextSwitch { id: headache; text: qsTr("Headache") }
            TextSwitch { id: fatigue; text: qsTr("Fatigue") }
            TextSwitch { id: bloating; text: qsTr("Bloating") }
            TextSwitch { id: sleep; text: qsTr("Sleep changes") }
            TextSwitch { id: stress; text: qsTr("Stress") }
            TextArea { id: notes; width: parent.width; label: qsTr("Notes"); placeholderText: qsTr("Example: unusually tired today") }
            Button { anchors.horizontalCenter: parent.horizontalCenter; preferredWidth: Theme.buttonWidthLarge; text: qsTr("Save record"); onClicked: saveRecord() }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: editingId >= 0 ? qsTr("Delete record") : qsTr("Discard without saving")
                onClicked: deleteOrDiscard()
            }
            Item { width: parent.width; height: Theme.paddingLarge }
        }
        VerticalScrollDecorator {}
    }
    RemorsePopup { id: deleteRemorse }

}
