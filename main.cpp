#include <QGuiApplication>
#include <QtQuick/QQuickView>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlEngine>
#include <QOpenGLContext>

#include <AtCore/AtCore>
#include "Plugins/GraphTemp/graphtemp.h"
#include "Plugins/Logger/logger.h"

#include "Plugins/WebQml/ql-files.hpp"
#include "Plugins/WebQml/ql-server.hpp"
#include "Plugins/Process/process.h"
#include "Plugins/QuickGCode/quickgcode.h"



int main(int argc, char *argv[])
{
    qputenv("XDG_CONFIG_HOME", QByteArray("/etc"));
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));
    qputenv("QT_QUICK_CONTROLS_CONF", QByteArray("/etc/thing-printer/qtquickcontrols2.conf"));


    QApplication app(argc, argv);
    QString extraImportPath(QStringLiteral("%1/../../../%2"));

    app.setOrganizationDomain("thing-printer.com");
    app.setOrganizationName("thing-printer");
    app.setApplicationName("atcore-bbk");
    app.setApplicationVersion("0.87.0");

    qmlRegisterType<AtCore>("org.kde.atcore", 1, 0, "AtCore");
    qmlRegisterType<QlFiles>("QlFiles", 1,0, "QlFiles");
    qmlRegisterType<QlServer>("QlServer", 1,0, "QlServer");
    qmlRegisterType<QuickGCode>("QuickGCode", 1, 0, "QuickGCode");
    qmlRegisterType<Process>("Process", 1, 0, "Process");

    QQuickView view;
    LogModel logmodel;
    GraphTemp  graphTemp(&view);

    view.rootContext()->setContextProperty("mylogmodel", &logmodel);
    view.rootContext()->setContextProperty("graphTemp", &graphTemp);

    view.setSource(QUrl("qrc:/Pages/MainPage.qml"));


    if (view.status() == QQuickView::Error)
        return -1;

    view.setResizeMode(QQuickView::SizeRootObjectToView);
#ifdef DESKTOP
    view.show();
#else
    view.showFullScreen();
#endif
    return app.exec();

}
