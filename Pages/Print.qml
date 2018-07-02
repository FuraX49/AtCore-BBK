import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Window 2.11
import QtQuick.Layouts 1.11
import QtQml 2.11

import org.kde.atcore 1.0
import "../Components"
import "../Components/ParseMsg.js" as PM

Page {
    id: printpage
    width: 800
    height: 480
    title: qsTr("Print")

    property string frE : " F"+mainpage.cfg_FeedRateE.toString()
    property alias printprogress : printProgress
    property var heattype : { "pla" : 1, "abs" : 2}

    function allHeatExt(onOff,typeheat){
        var newTemp
        if (onOff) {
            if (typeheat === heattype.abs) {
                if (heatBed.visible) heatBed.heatAt(onOff,cfg_BedABS,true);
                if (heatE0.visible) heatE0.heatAt(onOff,cfg_ExtABS,true);
                if (heatE1.visible) heatE1.heatAt(onOff,cfg_ExtABS,true);
                if (heatE2.visible) heatE2.heatAt(onOff,cfg_ExtABS,true);
                if (heatE3.visible) heatE3.heatAt(onOff,cfg_ExtABS,true);
            } else {
                if (heatBed.visible) heatBed.heatAt(onOff,cfg_BedPLA,true);
                if (heatE0.visible) heatE0.heatAt(onOff,cfg_ExtPLA,true);
                if (heatE1.visible) heatE1.heatAt(onOff,cfg_ExtPLA,true);
                if (heatE2.visible) heatE2.heatAt(onOff,cfg_ExtPLA,true);
                if (heatE3.visible) heatE3.heatAt(onOff,cfg_ExtPLA,true);
            }
        }  else {
            if (heatBed.visible) heatBed.heatOff(false);
            if (heatE0.visible) heatE0.heatOff(false);
            if (heatE1.visible) heatE1.heatOff(false);
            if (heatE2.visible) heatE2.heatOff(false);
            if (heatE3.visible) heatE3.heatOff(false);
        }
    }

    function updateHeater(TH) {
        var zero = 0.0
        if (heatBed.visible) {
//            heatBed.heatAt((TH.TargetBed>zero)?true:false,(TH.TargetBed>0)?TH.TargetBed:heatBed.currentTemp,false);
            heatBed.currentTemp=TH.Bed;
        }
        if (heatE0.visible) {
//            heatE0.heatAt((TH.TargetE0>zero)? true:false,(TH.TargetE0>zero)?TH.TargetE0:heatE0.currentTemp,false);
            heatE0.currentTemp=TH.E0;
        }
        if (heatE1.visible) {
//            heatE1.heatAt((TH.TargetE1>zero)? true:false,(TH.TargetE1>zero)?TH.TargetE1:heatE1.currentTemp,false);
            heatE1.currentTemp=TH.E1;
        }
        if (heatE2.visible) {
//            heatE2.heatAt((TH.TargetE2>zero)? true:false,(TH.TargetE2>zero)?TH.TargetE2:heatE2.currentTemp,false);
            heatE2.currentTemp=TH.E2;
        }
        if (heatE3.visible) {
//            heatE3.heatAt((TH.TargetE3>zero)? true:false,(TH.TargetE3>zero)?TH.TargetE3:heatE3.currentTemp,false);
            heatE3.currentTemp=TH.E3;
        }
    }


    GridLayout {
        id: gridLayout
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.margins: 10
        height: Math.floor(parent.height /2)
        rows: 3
        columns: 8
        rowSpacing: 10
        columnSpacing: 10

        PrintProgress {
            id: printProgress
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.row : 0
            Layout.column : 0
            Layout.rowSpan: 2
            Layout.columnSpan: 4
        }

        RateControl {
            id: rcSpeed
            Layout.fillHeight: true
            Layout.fillWidth: true
            title: "Speed"
            Layout.row : 0
            Layout.rowSpan: 1
            Layout.column : 4
            Layout.columnSpan: 3
            minRate: 50
            maxRate: 200
            currentRate : 100
            onRatechanged: {
                atcore.setPrinterSpeed(speed);
                terminal.appmsg("M220 " + speed.toString());
            }
        }

        RateControl {
            id: rcFlow
            Layout.fillHeight: true
            Layout.fillWidth: true
            title: "Flow"
            Layout.row : 1
            Layout.rowSpan: 1
            Layout.column : 4
            Layout.columnSpan: 3
            minRate: 10
            maxRate: 300
            currentRate : 100
            onRatechanged: {
                atcore.setFlowRate(speed);
                terminal.appmsg("M221 " + speed.toString());
            }
        }

        PrintButton {
            id: btnABS
            text: qsTr("ABS")
            font.pixelSize: fontSize14
            Layout.fillHeight: true
            Layout.fillWidth: true
            autoExclusive: false
            checkable: true
            Layout.row : 2
            Layout.rowSpan: 1
            Layout.column : 0
            Layout.columnSpan: 1
            onClicked: {
                if ( btnPLA.checked ) btnPLA.checked = false;
                if (checked) {
                    allHeatExt(true,heattype.abs)
                } else {
                    allHeatExt(false,heattype.abs)
                }
            }
        }

        PrintButton {
            id: btnPLA
            text: qsTr("PLA")
            font.pixelSize: fontSize14
            Layout.fillHeight: true
            Layout.fillWidth: true
            autoExclusive: false
            checkable: true
            Layout.row : 2
            Layout.rowSpan: 1
            Layout.column : 1
            Layout.columnSpan: 1
            onClicked: {
                if ( btnABS.checked ) btnABS.checked = false;
                if (checked) {
                    allHeatExt(true,heattype.pla)
                } else {
                    allHeatExt(false,heattype.pla)
                }
            }
        }


        PrintButton {
            id: btnRest
            text: qsTr("Reset")
            font.pixelSize: fontSize14
            Layout.fillHeight: true
            Layout.fillWidth: true
            autoExclusive: false
            checkable: false
            Layout.row : 2
            Layout.rowSpan: 1
            Layout.column : 3
            Layout.columnSpan: 1
            onClicked: {
                atcore.pushCommand("M562");
                terminal.appmsg("M562");
            }
        }

        PrintButton {
            id : tbMotorOff
            text : "Motors\nOFF"
            font.wordSpacing: 1
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.row : 0
            Layout.rowSpan: 1
            Layout.column : 7
            Layout.columnSpan: 1
            font.pixelSize: fontSize14
            font.weight: Font.ExtraBold
            onClicked: {
                atcore.pushCommand("M84");
                terminal.appmsg("M84");
            }
        }

        FanControl {
            id: fan
            Layout.fillHeight: true
            Layout.fillWidth: true
            title: "Fan\n0"
            Layout.row : 2
            Layout.rowSpan: 1
            Layout.column : 4
            Layout.columnSpan: 4
            onChangedspeedfan: {
                if (onoff) {
                    atcore.pushCommand("M106 P"+fan.toString()+" S"+speed.toString() );
                    terminal.appmsg("M106 P"+fan.toString()+" S"+speed.toString());
                } else {
                    atcore.pushCommand("M107 P"+fan.toString() );
                    terminal.appmsg("M107 P"+fan.toString());
                }
            }
        }

    }

    RowLayout {
        id: rowLayout
        anchors.bottom: parent.bottom
        anchors.top: gridLayout.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.margins:  10
        spacing: 10

        HeaterControl {
            id : heatBed
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            visible : true
            title: "Bed"
            maxTemp : 120
            optimalTemp: 60
            onHeatchanged: {
                terminal.appmsg("M140 " + temperature.toString());
                if (heat) {
                    atcore.setBedTemp(temperature,false);
                } else {
                    atcore.setBedTemp(0,false);
                }
            }
            onTempchanged: {
                terminal.appmsg("M140 " + temperature.toString());
                atcore.setBedTemp(temperature,false);
            }

        }

        HeaterControl {
            id : heatE0
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            visible : true
            title: "Ext 0"
            maxTemp : 300
            optimalTemp: 200
            onHeatchanged: {
                if (heat) {
                    terminal.appmsg("M104 P0 S" + temperature.toString());
                    atcore.setExtruderTemp(temperature,0,false);
                } else {
                    terminal.appmsg("M104 P0 S0");
                    atcore.setExtruderTemp(0,0,false);
                }
            }
            onTempchanged: {
                terminal.appmsg("M104 P0 S" + temperature.toString());
                atcore.setExtruderTemp(temperature,0,false);
            }
        }

        HeaterControl {
            id : heatE1
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            visible : true
            title: "Ext 1"
            maxTemp : 300
            optimalTemp: 200
            onHeatchanged: {
                if (heat) {
                    terminal.appmsg("M104 P1 S" + temperature.toString());
                    atcore.setExtruderTemp(temperature,1,false);
                } else {
                    terminal.appmsg("M104 P1 S0");
                    atcore.setExtruderTemp(0,1,false);
                }
            }
            onTempchanged: {
                terminal.appmsg("M104 P1 S" + temperature.toString());
                atcore.setExtruderTemp(temperature,1,false);
            }
        }

        HeaterControl {
            id : heatE2
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            visible : true
            title: "Ext 2"
            maxTemp : 300
            optimalTemp: 200
            onHeatchanged: {
                if (heat) {
                    terminal.appmsg("M104 P2 S" + temperature.toString());
                    atcore.setExtruderTemp(temperature,2,false);
                } else {
                    terminal.appmsg("M104 P2 S0" );
                    atcore.setExtruderTemp(0,2,false);
                }
            }
            onTempchanged: {
                terminal.appmsg("M104 P2 S" + temperature.toString());
                atcore.setExtruderTemp(temperature,2,false);
            }
        }
        HeaterControl {
            id : heatE3
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            visible : true
            title: "Ext 3"
            maxTemp : 300
            optimalTemp: 200
            onHeatchanged: {
                if (heat) {
                    terminal.appmsg("M104 P3 S" + temperature.toString());
                    atcore.setExtruderTemp(temperature,3,false);
                } else {
                    terminal.appmsg("M104 P3 S0");
                    atcore.setExtruderTemp(0,3,false);
                }
            }
            onTempchanged: {
                terminal.appmsg("M104 P3 S" + temperature.toString());
                atcore.setExtruderTemp(temperature,3,false);
            }
        }

        ExtruderControl {
            id: ext
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            onExtrude: {
                if (PM.getExtTemp(tools) >= cfg_ExtProt ) {
                    atcore.pushCommand("T"+tools);
                    atcore.pushCommand("M83");
                    atcore.pushCommand("G1 E+"+ length +frE)
                    atcore.pushCommand("M82");
                    terminal.appmsg("G1 T"+tools+" E+"+ length +frE);
                } else {
                    terminal.appmsg("Extruder protection at "+cfg_ExtProt+"°C") ;
                }
            }
            onRetract: {
                if (PM.getExtTemp(tools) >= cfg_ExtProt ) {
                    atcore.pushCommand("T"+tools);
                    atcore.pushCommand("M83");
                    atcore.pushCommand("G1 E-"+ length +frE)
                    atcore.pushCommand("M82");
                    terminal.appmsg("G1 T"+tools+" E-"+ length +frE);
                } else {
                    terminal.appmsg("Extruder protection at "+cfg_ExtProt+"°C") ;
                }
            }
        }

    }

    function init(){
        if (cfg_HeatBed ) {
            heatBed.visible=true;
            heatBed.maxTemp=cfg_MaxBedTemp;
            } else {heatBed.visible=false;}
        if (cfg_ExtCount >1 ) {
            heatE1.visible=true;
            heatE1.maxTemp=cfg_MaxExtTemp;
        } else {heatE1.visible=false; }
        if (cfg_ExtCount>2 ) {
            heatE2.visible=true;
            heatE2.maxTemp=cfg_MaxExtTemp;
        } else {heatE2.visible=false; }
        if (cfg_ExtCount>3 ) {
            heatE3.visible=true;
            heatE3.maxTemp=cfg_MaxExtTemp;
        } else {heatE3.visible=false; }
        ext.majNbToosl(cfg_ExtCount);
        fan.majNbFans(cfg_FanCount);
    }

}
