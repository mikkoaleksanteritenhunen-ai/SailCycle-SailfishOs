import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/Database.js" as DB
Page {
 id:page; allowedOrientations:Orientation.All
 property date rangeStart:new Date(new Date().getFullYear(),new Date().getMonth()-3,new Date().getDate())
 property date rangeEnd:new Date(); property var stats:({totals:{},flowCounts:{},symptomCounts:{},wellbeingCounts:[0,0,0,0,0],painCounts:[0,0,0,0,0,0]}); property string errorText:""
 function applyPreset(i){rangeEnd=new Date();if(i===0)rangeStart=new Date(rangeEnd.getFullYear(),rangeEnd.getMonth()-1,rangeEnd.getDate());else if(i===1)rangeStart=new Date(rangeEnd.getFullYear(),rangeEnd.getMonth()-3,rangeEnd.getDate());else if(i===2)rangeStart=new Date(rangeEnd.getFullYear(),rangeEnd.getMonth()-6,rangeEnd.getDate());else if(i===3)rangeStart=new Date(rangeEnd.getFullYear()-1,rangeEnd.getMonth(),rangeEnd.getDate());else if(i===4)rangeStart=new Date(2000,0,1);load()}
 function load(){errorText="";if(rangeStart>rangeEnd){errorText=qsTr("Start date must be before end date");return}try{stats=DB.rangeStatistics(DB.isoDate(rangeStart),DB.isoDate(rangeEnd));DB.saveSetting("statsStart",DB.isoDate(rangeStart));DB.saveSetting("statsEnd",DB.isoDate(rangeEnd))}catch(e){errorText=String(e)}}
 function countMap(map){var a=[];for(var k in map)a.push({name:k,count:map[k]});a.sort(function(x,y){return y.count-x.count});return a}
 Component.onCompleted:load(); onStatusChanged:if(status===PageStatus.Active)load()
 SilicaFlickable{anchors.fill:parent;contentHeight:col.height+Theme.paddingLarge;PullDownMenu{MenuItem{text:qsTr("Refresh statistics");onClicked:load()}}
  Column{id:col;width:parent.width;spacing:Theme.paddingSmall;PageHeader{title:qsTr("Statistics");description:qsTr("Selected period")}
   ComboBox{id:rangeBox;label:qsTr("Time range");onCurrentIndexChanged:if(currentIndex<5)applyPreset(currentIndex);menu:ContextMenu{MenuItem{text:qsTr("1 month")}MenuItem{text:qsTr("3 months")}MenuItem{text:qsTr("6 months")}MenuItem{text:qsTr("1 year")}MenuItem{text:qsTr("All records")}MenuItem{text:qsTr("Custom range")}}}
   ValueButton{label:qsTr("Start date");value:rangeStart.toLocaleDateString(Qt.locale(),Locale.ShortFormat);onClicked:startPicker.visible=!startPicker.visible}
   DatePicker{id:startPicker;visible:false;width:parent.width;date:rangeStart;onDateChanged:if(visible){rangeStart=date;load()}}
   ValueButton{label:qsTr("End date");value:rangeEnd.toLocaleDateString(Qt.locale(),Locale.ShortFormat);onClicked:endPicker.visible=!endPicker.visible}
   DatePicker{id:endPicker;visible:false;width:parent.width;date:rangeEnd;onDateChanged:if(visible){rangeEnd=date;load()}}
   Label{visible:errorText.length;width:parent.width-2*Theme.horizontalPageMargin;anchors.horizontalCenter:parent.horizontalCenter;text:errorText;color:Theme.highlightColor;wrapMode:Text.WordWrap}
   SectionHeader{text:qsTr("Data coverage")}
   DetailItem{label:qsTr("Selected period");value:rangeStart.toLocaleDateString(Qt.locale(),Locale.ShortFormat)+" - "+rangeEnd.toLocaleDateString(Qt.locale(),Locale.ShortFormat)}
   DetailItem{label:qsTr("Days with entries");value:String(stats.totals.entryDays||0)}
   DetailItem{label:qsTr("Wellbeing answers");value:String(stats.totals.wellbeing||0)} DetailItem{label:qsTr("Pain answers");value:String(stats.totals.pain||0)}
   SectionHeader{text:qsTr("How I felt")}
   DetailItem{label:qsTr("Average");value:stats.totals.wellbeing?stats.wellbeingAverage+" / 5":qsTr("No entries")}
   ScoreRow{symbolText:"☹";scoreText:"1";descriptionText:qsTr("Very low");count:stats.wellbeingCounts[0]||0;total:stats.totals.wellbeing||0;barColor:"#D76579"}
   ScoreRow{symbolText:"●";scoreText:"3";descriptionText:qsTr("Okay");count:stats.wellbeingCounts[2]||0;total:stats.totals.wellbeing||0;barColor:"#A889A5"}
   ScoreRow{symbolText:"☺";scoreText:"5";descriptionText:qsTr("Very good");count:stats.wellbeingCounts[4]||0;total:stats.totals.wellbeing||0;barColor:"#51D0D9"}
   SectionHeader{text:qsTr("Pain")}
   DetailItem{label:qsTr("Average");value:stats.totals.pain?stats.painAverage+" / 5":qsTr("No entries")} DetailItem{label:qsTr("Pain-free entries");value:String(stats.painCounts[0]||0)} DetailItem{label:qsTr("Pain affected activities");value:String(stats.totals.activityImpact||0)}
   SectionHeader{text:qsTr("Daily wellbeing")}
   DetailItem{label:qsTr("Average energy");value:stats.totals.energy?stats.energyAverage+" / 5":qsTr("No entries")} DetailItem{label:qsTr("Average sleep quality");value:stats.totals.sleep?stats.sleepAverage+" / 5":qsTr("No entries")} DetailItem{label:qsTr("Sleep disturbed by symptoms");value:String(stats.totals.sleepDisturbed||0)}
   SectionHeader{text:qsTr("Bleeding and flow")}
   DetailItem{label:qsTr("Spotting entries");value:String(stats.flowCounts.spotting||0)} DetailItem{label:qsTr("Light flow entries");value:String(stats.flowCounts.light||0)} DetailItem{label:qsTr("Medium flow entries");value:String(stats.flowCounts.medium||0)} DetailItem{label:qsTr("Heavy flow entries");value:String(stats.flowCounts.heavy||0)} DetailItem{label:qsTr("Bleeding affected activities");value:String(stats.totals.bleedingImpact||0)} DetailItem{label:qsTr("Bleeding outside expected period");value:String(stats.totals.outsideBleeding||0)} DetailItem{label:qsTr("Large clots recorded");value:String(stats.totals.largeClots||0)}
   SectionHeader{text:qsTr("Most recorded observations")}
   Repeater{model:countMap(stats.symptomCounts);DetailItem{visible:index<6;label:modelData.name;value:qsTr("%1 days").arg(modelData.count)}}
   Label{width:parent.width-2*Theme.horizontalPageMargin;anchors.horizontalCenter:parent.horizontalCenter;text:qsTr("Statistics summarize only your recorded entries. Missing answers are excluded and no medical conclusions are made.");color:Theme.secondaryColor;wrapMode:Text.WordWrap}
   Item{width:parent.width;height:Theme.paddingLarge}
  } VerticalScrollDecorator{}
 }
}
