TARGET = harbour-sail-cycle

CONFIG += sailfishapp c++11

SOURCES += \
    src/harbour-sail-cycle.cpp \
    src/filehelper.cpp

HEADERS += \
    src/filehelper.h

DISTFILES += \
    qml/harbour-sail-cycle.qml \
    qml/js/Database.js \
    qml/cover/CoverPage.qml \
    qml/images/flag-finland.png \
    qml/images/flag-europe.png \
    qml/pages/FirstPage.qml \
    qml/pages/LegendRow.qml \
    qml/pages/ScoreRow.qml \
    qml/pages/AddRecordPage.qml \
    qml/pages/CycleHistoryPage.qml \
    qml/pages/StatisticsPage.qml \
    qml/pages/SettingsPage.qml \
    qml/pages/BackupPage.qml \
    qml/pages/MenstruationInfoPage.qml \
    qml/pages/AboutPage.qml \
    harbour-sail-cycle.desktop

SAILFISHAPP_ICONS = \
    86x86 \
    108x108 \
    128x128 \
    172x172
