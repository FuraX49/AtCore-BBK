QT+=core qml svg quick quickcontrols2 widgets  serialport qmltest  network charts datavisualization
CONFIG += c++11
CONFIG += qtquickcompiler
#CONFIG += disable-desktop

QTPLUGIN += qtvirtualkeyboardplugin

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
    main.cpp \
    Plugins/GraphTemp/graphtemp.cpp \
    Plugins/Logger/logger.cpp \
    Plugins/WebQml/ql-server.cpp \
    Plugins/WebQml/ql-files.cpp


HEADERS += \
    Plugins/GraphTemp/graphtemp.h \
    Plugins/Logger/logger.h \
    Plugins/WebQml/ql-server.hpp \
    Plugins/WebQml/ql-files.hpp \
    Plugins/Process/process.h


RESOURCES += \
    pages.qrc \
    images.qrc \
    components.qrc \
    plugins.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
#QML_IMPORT_PATH += $$PWD/Pages \
#                   $$PWD/Components

#QML2_IMPORT_PATH += $$PWD/Pages \
#                    $$PWD/Components



# Additional import path used to resolve QML modules just for Qt Quick Designer
#QML_DESIGNER_IMPORT_PATH += $$PWD/Pages \
#                            $$PWD/Components


# Add AtCore library !!!


contains(QT_ARCH, "arm"):{
    message("Cross Compil for ARM")
    INCLUDEPATH +=$$[QT_SYSROOT]/usr/include/arm-linux-gnueabihf/AtCore

}

contains(QT_ARCH, "x86_64"):{
    DEFINES += DESKTOP
    message("Compil x86_64")
    INCLUDEPATH +=/usr/include/x86_64-linux-gnu/AtCore
}


unix:LIBS += -lAtCore




# Target install
unix:!android: target.path = /opt/atcore-bbk
!isEmpty(target.path): INSTALLS += target


# Web static file
DISTFILES += \
    static/atcore.html
webfile.files = static/atcore.html
webfile.path = /opt/atcore-bbk/static
DEPLOYMENT +=  webfile

