import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: contentColumn.height + Theme.paddingLarge

        PullDownMenu {
            MenuItem {
                text: qsTr("Open Medical Helpline 116117")
                onClicked: Qt.openUrlExternally("https://116117.fi/en")
            }
            MenuItem {
                text: qsTr("Open NHS period information")
                onClicked: Qt.openUrlExternally("https://www.nhs.uk/conditions/periods/")
            }
        }

        Column {
            id: contentColumn
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: qsTr("Cycle information")
                description: qsTr("Understanding records, estimates and symptoms")
            }

            SectionHeader { text: qsTr("What is a period?") }

            Label {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("A period is the part of the menstrual cycle when blood and tissue from the lining of the uterus leave the body. The first day of bleeding is cycle day 1.")
                color: Theme.primaryColor
                wrapMode: Text.WordWrap
            }

            Label {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("A menstrual cycle is counted from the first day of one period to the first day of the next. Cycle length and bleeding duration are individual and may change over time. A 28-day cycle is only a common reference value, not a target.")
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
            }

            SectionHeader { text: qsTr("What can I record?") }

            Label {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("• Period start and end dates\n• Flow level\n• Daily wellbeing\n• Pain level and pain locations\n• Energy and sleep quality\n• Effects on normal activities\n• Physical observations\n• Personal notes")
                color: Theme.primaryColor
                wrapMode: Text.WordWrap
            }

            Label {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("All daily questions are optional. An unanswered question is not treated as a symptom-free day. For example, pain level 0 means that you recorded no pain, while an unanswered pain question is excluded from statistics.")
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
            }

            SectionHeader { text: qsTr("Recorded information and estimates") }

            Label {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Recorded information is information you entered yourself. Estimated dates are calculated from the usual cycle settings or completed cycle history. Recorded information always takes priority over an estimate. Past estimates are not stored.")
                color: Theme.primaryColor
                wrapMode: Text.WordWrap
            }

            Column {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.paddingSmall

                Row {
                    spacing: Theme.paddingMedium
                    Rectangle { width: Theme.paddingLarge; height: width; radius: width / 2; color: "#E85D75" }
                    Label { text: qsTr("Recorded period day"); color: Theme.primaryColor }
                }
                Row {
                    spacing: Theme.paddingMedium
                    Rectangle { width: Theme.paddingLarge; height: width; radius: width / 2; color: "#EFA0AD" }
                    Label { text: qsTr("Current period estimate"); color: Theme.primaryColor }
                }
                Row {
                    spacing: Theme.paddingMedium
                    Rectangle { width: Theme.paddingLarge; height: width; radius: width / 2; color: "#A889A5" }
                    Label { text: qsTr("Next estimated period"); color: Theme.primaryColor }
                }
                Row {
                    spacing: Theme.paddingMedium
                    Rectangle { width: Theme.paddingLarge; height: width; radius: width / 2; color: "#63C174" }
                    Label { text: qsTr("Recorded period end"); color: Theme.primaryColor }
                }
                Row {
                    spacing: Theme.paddingMedium
                    Rectangle { width: Theme.paddingLarge; height: width; radius: width / 2; color: "#C7E86B" }
                    Label { text: qsTr("Estimated period end"); color: Theme.primaryColor }
                }
            }

            SectionHeader { text: qsTr("How are estimates calculated?") }

            Label {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("At first, Sail Cycle uses the usual cycle and period lengths selected in Settings. When completed cycles are available, the next period estimate can use recent cycles or all completed cycles, depending on the selected method.")
                color: Theme.primaryColor
                wrapMode: Text.WordWrap
            }

            Label {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("The estimated bleeding end is calculated from the recorded start date and the usual period length. Record the actual end date when known. Natural variation means that estimated dates may differ from actual dates.")
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
            }

            SectionHeader { text: qsTr("No safe-day calculation") }

            Label {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Sail Cycle does not identify safe, infertile or fertile days. Calendar and period estimates must not be used as contraception or for pregnancy-related decisions.")
                color: Theme.highlightColor
                font.bold: true
                wrapMode: Text.WordWrap
            }

            Label {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Ovulation timing can vary, including between cycles that appear regular. A period prediction alone cannot confirm whether pregnancy is or is not possible on a particular day. Sail Cycle does not confirm ovulation and does not protect against sexually transmitted infections.")
                color: Theme.primaryColor
                wrapMode: Text.WordWrap
            }

            SectionHeader { text: qsTr("Daily wellbeing and pain") }

            Label {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("The wellbeing scale records your own answer from 1, very low, to 5, very good. The pain scale records 0, no pain, to 5, very strong pain. Energy and sleep quality use separate optional scales.")
                color: Theme.primaryColor
                wrapMode: Text.WordWrap
            }

            Label {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Statistics summarize only the answers you recorded during the selected period. They may help you notice personal patterns, but do not explain why a change occurred and do not diagnose a condition.")
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
            }

            SectionHeader { text: qsTr("Understanding flow records") }

            Label {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Spotting, light, medium and heavy are personal descriptions. Sail Cycle counts the days on which each level was recorded, but does not calculate blood loss or classify bleeding medically.")
                color: Theme.primaryColor
                wrapMode: Text.WordWrap
            }

            Label {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("You can also record whether bleeding affected normal activities, occurred outside the expected period, or included large clots. These entries are personal observations and not diagnoses.")
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
            }

            SectionHeader { text: qsTr("Contact a healthcare professional") }

            Label {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Consider contacting a healthcare professional if:\n\n• bleeding or pain affects work, school, sleep or normal activities\n• periods become noticeably heavier, longer, more painful or different from what is usual for you\n• bleeding occurs between periods or after sex\n• periods stop unexpectedly without an expected explanation\n• symptoms continue, worsen or cause concern")
                color: Theme.primaryColor
                wrapMode: Text.WordWrap
            }

            SectionHeader { text: qsTr("Heavy bleeding may include") }

            Label {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("• changing period protection every 1 to 2 hours\n• needing two period products at the same time\n• bleeding through clothes or bedding\n• passing large clots\n• bleeding for more than 7 days\n• frequently feeling tired or short of breath")
                color: Theme.primaryColor
                wrapMode: Text.WordWrap
            }

            Label {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("These examples do not confirm heavy menstrual bleeding or another condition. A healthcare professional can assess symptoms and possible causes.")
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
            }

            SectionHeader { text: qsTr("Urgent help in Finland") }

            Label {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("For a sudden urgent health problem that is not life-threatening, contact Medical Helpline 116117 before seeking emergency care.")
                color: Theme.primaryColor
                wrapMode: Text.WordWrap
            }

            BackgroundItem {
                width: parent.width
                height: Theme.itemSizeLarge
                onClicked: Qt.openUrlExternally("https://116117.fi/en")
                Label {
                    anchors.centerIn: parent
                    text: qsTr("Open Medical Helpline 116117")
                    color: Theme.highlightColor
                }
            }

            Label {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("In a life-threatening emergency, call 112. Examples include unconsciousness, severe breathing difficulty or another immediate threat to life.")
                color: Theme.highlightColor
                font.bold: true
                wrapMode: Text.WordWrap
            }

            SectionHeader { text: qsTr("Preparing for an appointment") }

            Label {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Your records may help you describe:\n\n• period start and end dates\n• changes in cycle length\n• flow levels and bleeding observations\n• pain levels and pain locations\n• wellbeing, energy and sleep\n• effects on normal activities\n• personal notes and concerns")
                color: Theme.primaryColor
                wrapMode: Text.WordWrap
            }

            Label {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("A healthcare professional decides whether an examination, testing or treatment is needed. The application does not make this decision.")
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
            }

            SectionHeader { text: qsTr("Privacy and update backup") }

            Label {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Cycle records, wellbeing answers, pain scores and notes are stored locally on this phone. Sail Cycle does not send these records to the external information websites.")
                color: Theme.primaryColor
                wrapMode: Text.WordWrap
            }

            Label {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("An update safety backup may contain all records, scores, observations, notes and settings. Version 0.1 backup files are not encrypted. Keep the file private and use it only if an application update fails or cannot read the existing data.")
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
            }

            SectionHeader { text: qsTr("Trusted information") }

            BackgroundItem {
                width: parent.width
                height: Theme.itemSizeLarge
                onClicked: Qt.openUrlExternally("https://www.nhs.uk/conditions/periods/fertility-in-the-menstrual-cycle/")
                Label { anchors.centerIn: parent; text: qsTr("NHS: Periods and the menstrual cycle"); color: Theme.highlightColor }
            }

            BackgroundItem {
                width: parent.width
                height: Theme.itemSizeLarge
                onClicked: Qt.openUrlExternally("https://www.nhs.uk/conditions/heavy-periods/")
                Label { anchors.centerIn: parent; text: qsTr("NHS: Heavy periods"); color: Theme.highlightColor }
            }

            BackgroundItem {
                width: parent.width
                height: Theme.itemSizeLarge
                onClicked: Qt.openUrlExternally("https://www.acog.org/womens-health/infographics/the-menstrual-cycle")
                Label { anchors.centerIn: parent; text: qsTr("ACOG: The menstrual cycle"); color: Theme.highlightColor }
            }

            BackgroundItem {
                width: parent.width
                height: Theme.itemSizeLarge
                onClicked: Qt.openUrlExternally("https://www.cdc.gov/contraception/hcp/usmec/fertility-awareness-based-methods.html")
                Label { anchors.centerIn: parent; text: qsTr("CDC: Fertility-awareness methods"); color: Theme.highlightColor }
            }

            SectionHeader { text: qsTr("Important") }

            Label {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Sail Cycle is a personal record and calendar application, not a medical device. It does not diagnose conditions, confirm ovulation, identify safe days or provide contraceptive guidance. Contact a healthcare professional if symptoms or changes concern you.")
                color: Theme.highlightColor
                wrapMode: Text.WordWrap
            }

            Label {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Information sources: NHS, ACOG, CDC and Finland Medical Helpline 116117. External pages may change after this application version is released.")
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.WordWrap
            }

            Item { width: parent.width; height: Theme.paddingLarge }
        }

        VerticalScrollDecorator { flickable: flickable }
    }
}
