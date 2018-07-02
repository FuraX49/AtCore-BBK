import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11


Pane {
    id: control
    implicitHeight : 180
    implicitWidth:  80
    padding: 2
    property string title: "Ext 0"
    property int maxTemp : 300
    property int minTemp: 0
    property int optimalTemp: 200
    property int targetTemp: optimalTemp
    property int currentTemp: 0.0
    property real stepsize : 5
    property int bottomY: 0
    property int borderWidth: 2

    signal heatchanged (bool heat,real  temperature)
    signal tempchanged (real  temperature)


    function heatAt( onoff, temperature, update) {
        targetTemp=temperature;
        btnOnOff.checked = onoff;
    }

    function heatOff( onoff) {
        btnOnOff.checked = onoff;
    }

    function emitTempChanged(){
        if (btnOnOff.checked)
            tempchanged (control.targetTemp)
    }

    Timer {
        id :timerSaisie
        triggeredOnStart : false
        interval: 4000
        running: false
        onTriggered: {
            if (running) {
                lab_Temps.visible=false;
                tf_Target.visible=true;
            } else {
                if (!inputPanel.active) {
                    lab_Temps.visible=true;
                    tf_Target.visible=false;
                }
            }
        }
    }




    ColumnLayout {
        id: colroot
        anchors.fill: parent
        spacing: 0
        Label {
            id: titre
            text: control.title
            padding: 0
            Layout.fillHeight: true
            Layout.maximumHeight: Math.floor(parent.height *0.10)
            Layout.fillWidth: true
            Layout.margins:  4
            font.bold: false
            font.pixelSize: fontSize12
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }

        RoundButton {
            id: more
            text: "+"
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            hoverEnabled: true
            font.bold: true
            font.pixelSize: fontSize12
            wheelEnabled: false
            autoRepeat: true
            Layout.margins:  4
            Layout.maximumHeight: Math.floor(parent.height *0.20)
            Layout.preferredWidth: Math.floor(parent.width *0.8)
            Layout.preferredHeight:Math.floor( more.width *0.20)
            Layout.minimumHeight: 20
            flat : false
            onReleased: {
                if ( pressed )  {
                    if (targetTemp+stepsize<maxTemp){
                        targetTemp+=stepsize;
                    } else {
                        targetTemp=maxTemp;
                    }
                } else {
                    if (targetTemp<maxTemp){
                        targetTemp++;
                    }
                }
                emitTempChanged();
                timerSaisie.start();
            }
        }

        RowLayout {
            Layout.maximumHeight: Math.floor(parent.height *0.30)
            Layout.preferredHeight:Math.floor( more.width *0.30)
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins:  4
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            spacing : 0
            Label {
                id : lab_Temps
                visible: true
                text: control.currentTemp.toString() + "/" +control.targetTemp.toString()
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: fontSize14
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
            TextField {
                id: tf_Target
                visible: false
                padding: 0
                text:control.targetTemp.toString()
                inputMethodHints: Qt.ImhDigitsOnly
                validator: IntValidator {bottom: control.minTemp; top: control.maxTemp;}
                font.pixelSize: fontSize16
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                onEditingFinished: {
                    if (acceptableInput) {
                        control.targetTemp=text.valueOf();
                    }
                    focus = false;
                    timerSaisie.start();
                }
            }



        }
        RoundButton {
            id: less
            text: "-"
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            hoverEnabled: true
            font.bold: true
            font.pixelSize: fontSize12
            wheelEnabled: false
            autoRepeat: true
            Layout.margins:  4
            Layout.maximumHeight: Math.floor(parent.height *0.20)
            Layout.preferredWidth: Math.floor(parent.width *0.8)
            Layout.preferredHeight: Math.floor(more.width *0.20)
            Layout.minimumHeight: 20
            flat : false
            onReleased: {
                if ( pressed ) {
                    if (targetTemp+stepsize>minTemp) {
                        targetTemp-=stepsize;
                    } else {
                        targetTemp=minTemp;
                    }
                } else {
                    if (targetTemp>minTemp) {
                        targetTemp--;
                    }
                }
                emitTempChanged();
                timerSaisie.start();
            }

        }

        Button {
            id: btnOnOff
            text: qsTr("ON")
            font.pixelSize: fontSize12
            Layout.minimumHeight:  Math.floor( parent.height *0.20)
            Layout.preferredHeight: 30
            Layout.maximumHeight: Math.floor( parent.height *0.20)
            Layout.fillHeight: true
            Layout.fillWidth: true
            hoverEnabled: true
            checked: false
            checkable: true
            flat : false
            Layout.margins:  4
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            onCheckedChanged: {
                if (checked==true) {
                    text = qsTr("Off")
                    control.heatchanged (true,control.targetTemp)
                }   else {
                    text = qsTr("On")
                    control.heatchanged (false,control.targetTemp)
                }
            }
        }
    }

    background: Rectangle {
        id : rectControl
        radius: 4
        color: control.palette.window
        border.width: borderWidth
        border.color: control.palette.buttonText

        gradient: Gradient {
            GradientStop { position: 0.0; color: btnOnOff.checked? "red" : control.palette.window }
            GradientStop { position: control.targetTemp/control.maxTemp; color:  btnOnOff.checked? "yellow" : control.palette.window }
            GradientStop { position: 1.0; color: btnOnOff.checked?"blue" : control.palette.window  }
        }

        Rectangle {
            id : markTarget
            color : control.palette.window
            width : parent.width - borderWidth*2
            x :borderWidth
            height :5
            border.width: 1
            border.color: control.palette.buttonText
            y : control.contentHeight- ((control.contentHeight/control.maxTemp) * control.targetTemp );
        }

        Rectangle {
            id : markCurrent
            color : control.palette.buttonText
            x :borderWidth
            width : parent.width - borderWidth*2
            height :3
            y : control.contentHeight- ((control.contentHeight/control.maxTemp) * control.currentTemp );
        }
    }


    onHeightChanged:
    {
        control.bottomY=control.y+control.height -control.borderWidth*2;
        contentHeight = control.height -control.borderWidth*2
        contentWidth =  control.width -control.borderWidth*2
    }

}

