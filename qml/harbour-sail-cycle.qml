import QtQuick 2.0
import Sailfish.Silica 1.0

ApplicationWindow {
    id: appWindow

    initialPage: Qt.resolvedUrl("pages/FirstPage.qml")
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    allowedOrientations: defaultAllowedOrientations
}
