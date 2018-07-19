import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Window 2.11
import QtQuick.Layouts 1.11

import org.kde.atcore 1.0
import "../Components"
import "../Components/ParseMsg.js" as PM


Page {
    id: jog
    title: qsTr("Jog")

    property string frXY : " F"+cfg_FeedRateXY.toString()
    property string frZ : " F"+ cfg_FeedRateZ.toString()
    width: 800
    height: 480

    function updatePos(PosAxe) {
        lbpX.text=PosAxe.X.toString();
        lbpY.text=PosAxe.Y.toString();
        lbpZ.text=PosAxe.Z.toString();
    }

    function updateES(EndStop) {
        homeX.es1  = EndStop.X1;
        homeX.es2  = EndStop.X2;
        homeY.es1  = EndStop.X2;
        homeY.es2  = EndStop.Y1;
        homeZ.es1  = EndStop.Y2;
        homeZ.es2  = EndStop.Z1;
    }

    function jogCmd(cmd) {
        atcore.setRelativePosition();
        atcore.pushCommand(cmd);
        terminal.appmsg(cmd);
        atcore.setAbsolutePosition();
    }

    Timer {
        interval: 1000; running: false; repeat: true
        onTriggered: {
            console.log("Timer JOG")
            if (jog.visible) {
                atcore.pushCommand("M114");
                atcore.pushCommand("M119");
            }
        }
    }


    RowLayout {
        id: rowaxes
        height: fontSize12 * 2
        implicitHeight:  60
        implicitWidth:  400
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.margins: fontSize10
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        spacing : fontSize14

        // Coord
        Label {
            id: lbX
            text: qsTr("X:")
            horizontalAlignment: Text.AlignRight
            font.bold: false
            font.pixelSize: fontSize14
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            Layout.column : 0
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Label {
            id: lbpX
            text: "000"
            font.bold: true
            font.pixelSize: fontSize14
            horizontalAlignment: Text.AlignLeft | Qt.AlignVCenter
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            Layout.column : 1
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Label {
            id: lbY
            text: qsTr("Y:")
            horizontalAlignment: Text.AlignRight
            font.bold: false
            font.pixelSize: fontSize14
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            Layout.column : 2
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Label {
            id: lbpY
            text: "000"
            horizontalAlignment: Text.AlignLeft | Qt.AlignVCenter
            font.bold: true
            font.pixelSize: fontSize14
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            Layout.column : 3
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
        Label {
            id: lbZ
            text: qsTr("Z:")
            font.bold: false
            font.pixelSize: fontSize14
            horizontalAlignment: Text.AlignRight
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            Layout.column : 4
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Label {
            id: lbpZ
            text: "000"
            font.bold: true
            font.pixelSize: fontSize14
            Layout.column : 5
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    GridLayout {
        id: gridLayout
        columnSpacing: 5
        rowSpacing: 5
        clip: false
        anchors.bottom: rowstep.top
        anchors.margins: fontSize12

        anchors.top: rowaxes.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        //        rowSpacing: fontSize12
        //        columnSpacing: fontSize12
        rows: 3
        columns: 6
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        Layout.fillHeight: true
        Layout.fillWidth: true

        // XY
        JogButton {
            id: mY
            text: qsTr("+Y")
            image {source : "qrc:/Images/jog/up.svg"}
            homebutton:  false
            autoRepeat: true
            autoExclusive: true
            Layout.column : 1
            Layout.row : 0
            Layout.fillHeight: true
            Layout.fillWidth: true
            onClicked: {
                if (!cfg_invertY) {
                    jogCmd("G1 Y+"+ step.jogsize + frXY );
                } else {
                    jogCmd("G1 Y-"+ step.jogsize + frXY );
                }
            }
        }

        JogButton {
            id: mZ
            text: qsTr("+Z")
            image {source : "qrc:/Images/jog/up.svg"}
            homebutton:  false
            autoRepeat: true
            autoExclusive: true
            Layout.column : 3
            Layout.row : 0
            Layout.fillHeight: true
            Layout.fillWidth: true
            onClicked: {
                if (!cfg_invertZ) {
                    jogCmd("G1 Z+"+ step.jogsize + frZ);
                } else {
                    jogCmd("G1 Z-"+ step.jogsize + frZ);
                }
            }
        }


        JogButton {
            id: lX
            text: qsTr("-X")
            image { source : "qrc:/Images/jog/left.svg"}
            homebutton:  false
            autoRepeat: true
            autoExclusive: true
            Layout.column : 0
            Layout.row : 1
            Layout.fillHeight: true
            Layout.fillWidth: true
            onClicked: {
                if (!cfg_invertX) {
                    jogCmd("G1 X-"+ step.jogsize+ frXY);
                } else {
                    jogCmd("G1 X+"+ step.jogsize+ frXY);
                }
            }
        }

        JogButton {
            id: mX
            autoExclusive: true
            text: qsTr("+X")
            image {source : "qrc:/Images/jog/right.svg" }
            homebutton:  false
            autoRepeat: true
            Layout.column : 2
            Layout.row : 1
            Layout.fillHeight: true
            Layout.fillWidth: true
            onClicked: {
                if (!cfg_invertX) {
                    jogCmd("G1 X+"+ step.jogsize + frXY );
                } else {
                    jogCmd("G1 X-"+ step.jogsize + frXY );
                }
            }
        }



        JogButton {
            id: lY
            text: qsTr("-Y")
            image { source : "qrc:/Images/jog/down.svg" }
            homebutton:  false
            autoRepeat: true
            autoExclusive: true
            Layout.column : 1
            Layout.row : 2
            Layout.fillHeight: true
            Layout.fillWidth: true
            onClicked: {
                if (!cfg_invertY) {
                    jogCmd("G1 Y-"+ step.jogsize +frXY);
                } else {
                    jogCmd("G1 Y+"+ step.jogsize +frXY);
                }
            }
        }

        JogButton {
            id: lZ
            text: qsTr("-Z")
            bottomPadding: 0
            topPadding: 0
            spacing: 0
            image { source : "qrc:/Images/jog/down.svg" }
            homebutton:  false
            autoRepeat: true
            autoExclusive: true
            Layout.column : 3
            Layout.row : 2
            Layout.fillHeight: true
            Layout.fillWidth: true
            onClicked: {
                if (!cfg_invertZ) {
                    jogCmd("G1 Z-"+step.jogsize + frZ);
                } else {
                    jogCmd("G1 Z+"+step.jogsize + frZ);
                }
            }
        }

        // home
        JogButton {
            id: homeX
            text: "X"
            homebutton:  true
            autoExclusive: true
            Layout.column : 5
            Layout.row : 0
            Layout.fillHeight: true
            Layout.fillWidth: true
            onClicked: {
                atcore.home(AtCore.X);
                terminal.appmsg("G28 X0");
            }
        }

        JogButton {
            id: homeY
            homebutton:  true
            text: "Y"
            autoExclusive: true
            Layout.column : 5
            Layout.row : 1
            Layout.fillHeight: true
            Layout.fillWidth: true
            onClicked: {
                atcore.home(AtCore.Y);
                terminal.appmsg("G28 Y0");
            }

        }

        JogButton {
            id: homeall
            homebutton:  true
            text: "ALL"
            font.weight: Font.ExtraBold
            autoExclusive: true
            Layout.column : 4
            Layout.row :  1
            Layout.fillHeight: true
            Layout.fillWidth: true
            onClicked: {
                atcore.home();
                terminal.appmsg("G28");
            }
        }

        JogButton {
            id: homeZ
            text: "Z"
            homebutton:  true
            font.pixelSize: fontSize30
            font.weight: Font.ExtraBold
            font.wordSpacing: 1
            autoExclusive: true
            Layout.column : 5
            Layout.row : 2
            Layout.fillHeight: true
            Layout.fillWidth: true
            onClicked: {
                atcore.home(AtCore.Z);
                terminal.appmsg("G28 Z0");
            }
        }

    }

    RowLayout {
        id: rowstep

        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.margins: fontSize12
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        Layout.fillHeight: true
        Layout.fillWidth: true
        spacing: fontSize12 /2


        StepBox {
            id : step
            topPadding: 5
            padding: 0
            Layout.columnSpan: 2
            font.pixelSize: fontSize12
            font.bold: true
            Layout.fillHeight: true
            Layout.fillWidth: true

        }

        PrintButton {
            id : tbMotorOff
            text : "Motor OFF"
            font.pixelSize: fontSize16
            font.weight: Font.ExtraBold
            Layout.fillHeight: true
            Layout.fillWidth: true
            onClicked: {
                atcore.pushCommand("M84");
                terminal.appmsg("M84");
            }
        }

        PrintButton {
            id : tbDock
            text : checked?"Dock":"UnDock"
            checkable: true
            font.pixelSize: fontSize16
            font.weight: Font.ExtraBold
            Layout.fillHeight: true
            Layout.fillWidth: true
            onClicked: {
                if (checked) {
                    atcore.pushCommand("G31");
                    terminal.appmsg("G31");
                } else {
                    atcore.pushCommand("G32");
                    terminal.appmsg("G32");
                }
            }
        }



        PushCombo {
            id: cb_CmdMacros
            font.pixelSize: fontSize12
            Layout.fillHeight: true
            Layout.fillWidth: true
            onExecClicked: {
                terminal.appmsg(macro);
                atcore.pushCommand(macro);
            }

        }



        PrintButton {
            id : tbProbeChart
            text : "Matrix"
            //enabled: PM.isMatrixDispo?true:false
            font.pixelSize: fontSize16
            font.weight: Font.ExtraBold
            Layout.fillHeight: true
            Layout.fillWidth: true
            onClicked: {
                bedmatrix.open();
            }
        }

    }
    BedMatrix {
        id : bedmatrix
    }

    /*

    Button{
        onClicked: {
            var datamodel = []
            for (var i = 0; i < cb_CmdMacros.macros.count; ++i)  {
                datamodel.push(cb_CmdMacros.macros.get(i));
                console.log( "I :" +i +" M :" + cb_CmdMacros.macros.get(i))
            }
            console.log(datamodel);
            cfg_Macros = JSON.stringify(datamodel);
        }
    }

    function test(){
        PM.strmsg = "Homing done at";
        PM.getHoming();
        for (var x = 20; x < 280 ; x+=50) {
            for (var y = 20; y < 180 ; y+=50) {
                PM.strmsg = "Found Z probe distance -" +Math.round(1) + ".01 mm at (X, Y) = (" + x +".00, "+y+".00)";
                PM.getProbePoint();
            }
        }
        PM.strmsg = "Current bed compensation matrix";
        PM.getMatrixDispo();
    }
*/

    function init(){
        if (cfg_Macros.length>0) {
            try {
                cb_CmdMacros.macros.clear();
                var datamodel = JSON.parse(cfg_Macros);
                for (var i = 0; i < datamodel.length; ++i) cb_CmdMacros.macros.append(datamodel[i]);
            }
            catch (E) {
                console.log("Error when append jog macros")
            }
        }
    }


}
