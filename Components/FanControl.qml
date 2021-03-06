import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11

PaneBorder {
    id: control

    implicitHeight: 50
    implicitWidth: 200
    property string title: "Fan\n0"
    property real maxSpeed : 100
    property real minSpeed: 0
    property real currentSpeed: 100
    property real stepsize : 5

    signal changedspeedfan (int fan,bool onoff,real  speed)

    property var speedfan  : [100,100,100,100,100]
    property var offan  : [false,false,false,false,false]
    property int fanindex  : 0

    function majNbFans(nb) {
        while (speedfan.length> nb) {speedfan.pop();}
        while (speedfan.length< nb) {speedfan.push(100);}
        speedfan.length=nb;
    }

    RowLayout {
        id: row
        spacing: 0
        anchors.fill: parent


        Slider {
            id: slider
            clip: false
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.maximumWidth: parent.width * 0.6
            Layout.margins: 2
            snapMode: Slider.SnapOnRelease
            orientation: Qt.Horizontal
            value: control.currentSpeed
            from : control.minSpeed
            to   : control.maxSpeed
            stepSize : control.stepsize
            background: Text {
                id: name
                text: slider.value.toString()
                font.weight: Font.Light
                font.pixelSize: fontSize10
                color: control.palette.buttonText
                width : parent.width
                height: parent.height
            }
            onValueChanged: {
                speedfan[fanindex]=value;
                if (offan[fanindex]) {
                    changedspeedfan(fanindex,true,speedfan[fanindex]);
                }
            }
        }

        Button {
            id: precFan
            Layout.margins: 2
            Layout.rightMargin: 0
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.maximumWidth: Math.floor(parent.width * 0.1)
            text: "-"
            font.bold: true
            font.pixelSize: fontSize14
            enabled: (fanindex>0)
            onClicked: {
                 if (fanindex>0) {
                     fanindex--;
                     toolButton.text="Fan\n"+fanindex.toString();
                     slider.value=speedfan[fanindex];
                     toolButton.checked= offan[fanindex];
                 }
            }
        }

        Button {
            id: toolButton
            text: control.title
            spacing: 0
            padding: 0
            topPadding: -fontSize12 /2
            checkable: true
            checked: false
            font.pixelSize: fontSize12
            Layout.margins: 2
            Layout.leftMargin: 0
            Layout.rightMargin: 0
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.maximumWidth: Math.floor(parent.width * 0.2)
            onClicked: {
                offan[fanindex]=checked;
                changedspeedfan(fanindex,checked,speedfan[fanindex]);
                //atcore.setFanSpeed(slider.value,cbFans.currentIndex);
            }
        }

        Button {
            id: nextFan
            Layout.leftMargin: 0
            Layout.margins: 2
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.maximumWidth: Math.floor(parent.width * 0.1)
            text: "+"
            font.bold: true
            font.pixelSize: fontSize14
            enabled: (fanindex<speedfan.length-1)
            onClicked: {
                if (fanindex<speedfan.length-1) {
                    fanindex++;
                    toolButton.text="Fan\n"+fanindex.toString();
                    slider.value=speedfan[fanindex];
                    toolButton.checked= offan[fanindex];
                }
            }

        }


    }
}
