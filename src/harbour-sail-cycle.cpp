#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <QGuiApplication>
#include <QQmlContext>
#include <QQuickView>
#include <sailfishapp.h>

#include "filehelper.h"

int main(int argc, char *argv[])
{
    QGuiApplication *app = SailfishApp::application(argc, argv);
    QQuickView *view = SailfishApp::createView();
    FileHelper fileHelper;

    view->rootContext()->setContextProperty(QStringLiteral("fileHelper"), &fileHelper);
    view->setSource(SailfishApp::pathTo(QStringLiteral("qml/harbour-sail-cycle.qml")));
    view->show();

    return app->exec();
}
