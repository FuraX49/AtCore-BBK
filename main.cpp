#include <QGuiApplication>
//#include <QtQuick/QQuickView>
#include <QQmlApplicationEngine>
#include <QOpenGLContext>
#include <QQmlContext>
#include <QQmlEngine>


#include <AtCore/AtCore>
#include "Plugins/GraphTemp/graphtemp.h"
#include "Plugins/Logger/logger.h"

#include "Plugins/WebQml/ql-files.hpp"
#include "Plugins/WebQml/ql-server.hpp"
#include "Plugins/Process/process.h"

//#include "plugins/gcodemesh.h"


void setSurfaceFormat()
{
    QSurfaceFormat format;
#ifdef QT_OPENGL_ES_2
    QCoreApplication::setAttribute(Qt::AA_UseOpenGLES, true);
    format.setRenderableType(QSurfaceFormat::OpenGLES);
    format.setVersion(2, 0);
    format.setRedBufferSize(5);
    format.setGreenBufferSize(6);
    format.setBlueBufferSize(5);
    format.setAlphaBufferSize(0);
    format.setDepthBufferSize(0);
#else
    if (QOpenGLContext::openGLModuleType() == QOpenGLContext::LibGL) {
        format.setVersion(4, 3);
        format.setProfile(QSurfaceFormat::CoreProfile);
        format.setDepthBufferSize(24);
        format.setSamples(4);
        format.setStencilBufferSize(8);
    }
#endif

    QSurfaceFormat::setDefaultFormat(format);
}





int main(int argc, char *argv[])
{
    qputenv("XDG_CONFIG_HOME", QByteArray("/etc"));
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));
    qputenv("QT_QUICK_CONTROLS_CONF", QByteArray("/etc/thing-printer/qtquickcontrols2.conf"));


    QApplication app(argc, argv);
    app.setAttribute(Qt::AA_DisableHighDpiScaling);
    app.setAttribute(Qt::AA_UseHighDpiPixmaps, false);
    app.setOrganizationDomain("thing-printer.com");
    app.setOrganizationName("thing-printer");
    app.setApplicationName("atcore-bbk");
    app.setApplicationVersion("0.8.4");


    qmlRegisterType<AtCore>("org.kde.atcore", 1, 0, "AtCore");
    qmlRegisterType<QlFiles>("QlFiles", 1,0, "QlFiles");
    qmlRegisterType<QlServer>("QlServer", 1,0, "QlServer");
    qmlRegisterType<Process>("Process", 1, 0, "Process");
    //  qmlRegisterType<GCodeMesh>("GCodeMesh", 1, 0, "GCodeMesh");


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
