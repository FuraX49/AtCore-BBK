import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11

Dialog {
    id: control
    x : Math.floor((parent.width/2) - (width/2))
    y : Math.floor((parent.height/2) - (height/2))
    modal: true
    margins: 10
    parent : Overlay.overlay



    function show(titre,message) {
        popdialog.title=titre;
        msg.text=message;
        popdialog.visible = true;
    }
    title: "Title"
    visible : false
    Text {
        id : msg
        text: "message..."
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 4
        color: popdialog.palette.buttonText
    }
    standardButtons:Dialog.Ok
    footer: DialogButtonBox {
        alignment : Qt.AlignHCenter
    }
    onAccepted: {
        popdialog.visible = false;
        popdialog.close();
    }

    background: Rectangle {
        radius: 2
        color: control.palette.window
        border.width: 4
        border.color: control.palette.dark
    }
}
