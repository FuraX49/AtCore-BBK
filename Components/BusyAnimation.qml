import QtQuick 2.11
import QtQuick.Controls 2.4

BusyIndicator {
    id : libBusyIndicator
    property alias imagesource: image.source
    enabled: false
    running: false
    visible: false
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    width: Math.floor(parent.width /2)
    height: Math.floor(parent.height /2)
    opacity: 0.6

    function anim(onoff){
        if (onoff) {
            libBusyIndicator.enabled = true;
            libBusyIndicator.visible = true;
            libBusyIndicator.running = true;
        } else {
            libBusyIndicator.enabled = false;
            libBusyIndicator.visible = false;
            libBusyIndicator.running = false;
        }
    }

    background: Image {
        id: image
        width: parent.width
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        fillMode: Image.PreserveAspectFit
        source: "qrc:/Images/lib/atcore.png"
    }
}
