import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Window 2.11
import QtQuick.Layouts 1.11


Page {
    id: settingpage
    width: 800
    height: 480
    property alias btnConnect: btnConnect

    title: qsTr("Setting")


    GridLayout {
        id: gridh
        height: parent.height * 0.33
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: parent.top
        rows: 3
        columns: 7
        anchors.margins:  fontSize12 *2

        //row 0
        Label {
            width: 100
            text: qsTr("     Device :")
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            Layout.fillWidth: false
            verticalAlignment: Text.AlignVCenter
            font.bold: false
            font.pixelSize: fontSize12
            horizontalAlignment: Text.AlignRight
            Layout.fillHeight:  true
            Layout.columnSpan: 1

        }
        ComboBox {
            id: cb_Device
            width: 300
            font.bold: true
            font.pixelSize: fontSize12
            editable: true
            Layout.fillHeight: false
            Layout.fillWidth: true
            hoverEnabled: true
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.text: "Choose serial device in /dev like ttyACM0"
            ToolTip.visible: hovered
            Layout.columnSpan: 3
        }


        Label {
            width: 100
            text: qsTr("Fee Rate XY")
            verticalAlignment: Text.AlignVCenter
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            horizontalAlignment: Text.AlignRight
            Layout.fillWidth: true
            Layout.fillHeight: false
            font.pixelSize: fontSize12
            Layout.columnSpan: 1
        }

        SpinBox {
            id: sb_FeedRateXY
            width: 200
            Layout.fillWidth: true
            font.pixelSize: fontSize12
            font.bold: true
            from: 10
            to: 10000
            value: cfg_FeedRateXY.valueOf()
            stepSize: 100
            Layout.columnSpan: 2

        }


        // _________________row 1
        Label {
            text: qsTr("Firmware :")
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            verticalAlignment: Text.AlignVCenter
            font.bold: false
            font.pixelSize: fontSize12
            horizontalAlignment: Text.AlignRight
            Layout.fillWidth: true
            Layout.fillHeight:  true
            Layout.columnSpan: 1
        }


        ComboBox {
            id: cb_Firmware
            font.bold: true
            font.pixelSize: fontSize12
            editable: false
            Layout.fillHeight: false
            Layout.fillWidth: true
            hoverEnabled: true
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.text: "Leave blank for autodetect"
            ToolTip.visible: hovered
            Layout.columnSpan: 3
        }

        Label {
            text: qsTr(" Fee Rate Z")
            verticalAlignment: Text.AlignVCenter
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            horizontalAlignment: Text.AlignRight
            Layout.fillWidth: true
            Layout.fillHeight: false
            font.pixelSize: fontSize12
            Layout.columnSpan: 1
        }

        SpinBox {
            id: sb_FeedRateZ
            Layout.fillWidth: true
            font.pixelSize: fontSize12
            font.bold: true
            editable : true
            inputMethodHints: Qt.ImhDigitsOnly
            from: 10
            to: 10000
            value: cfg_FeedRateZ.valueOf()
            stepSize: 50
            Layout.columnSpan: 2
        }

        // ________________________row 2
        Label {
            text: qsTr("     Speed :")
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            verticalAlignment: Text.AlignVCenter
            font.bold: false
            font.pixelSize: fontSize12
            horizontalAlignment: Text.AlignRight
            Layout.fillWidth: true
            Layout.fillHeight:  true
            Layout.columnSpan: 1
        }

        ComboBox {
            id: cb_PortSpeed
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            font.bold: true
            font.pixelSize: fontSize12
            Layout.fillHeight: false
            Layout.fillWidth: true
            hoverEnabled: true
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.text: "Choose serial speed"
            ToolTip.visible: hovered
            Layout.columnSpan: 3
        }
        Label {
            text: qsTr(" Fee Rate E")
            verticalAlignment: Text.AlignVCenter
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            horizontalAlignment: Text.AlignRight
            Layout.fillWidth: true
            Layout.fillHeight: false
            font.pixelSize: fontSize12
            Layout.columnSpan: 1
        }

        SpinBox {
            id: sb_FeedRateE
            Layout.fillWidth: true
            font.pixelSize: fontSize12
            font.bold: true
            editable : true
            inputMethodHints: Qt.ImhDigitsOnly
            from: 10
            to: 2000
            value: cfg_FeedRateE.valueOf()
            stepSize: 10
            Layout.columnSpan: 2
        }
    }

    GridLayout {
        id: gridb
        anchors.top: gridh.bottom
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        rows: 6
        columns: 7
        anchors.margins:  fontSize12 *2


        // ________________________________row 3
        CheckBox {
            id: cb_HeatBed
            text: qsTr("Heat Bed Present")
            checked: true
            display: AbstractButton.TextOnly
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            font.pixelSize: fontSize12
            Layout.fillWidth: true
            Layout.columnSpan: 1
        }

        Label {
            text: qsTr("Ext. count:")
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            horizontalAlignment: Text.AlignRight
            Layout.fillWidth: true
            Layout.fillHeight: false
            font.pixelSize: fontSize12
            Layout.columnSpan: 1
        }
        SpinBox {
            id: sb_ExtCount
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillWidth: true
            font.pixelSize: fontSize12
            font.bold: true
            from: 1
            to: 4
            value: cfg_ExtCount.valueOf()
            Layout.columnSpan: 2
        }



        Label {
            text: qsTr("Fan count:")
            verticalAlignment: Text.AlignVCenter
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            horizontalAlignment: Text.AlignRight
            Layout.fillWidth: true
            Layout.fillHeight: false
            font.pixelSize: fontSize12
            font.bold: false
            Layout.columnSpan: 1
        }

        SpinBox {
            id: sb_FanCount
            Layout.fillWidth: true
            font.pixelSize: fontSize12
            font.bold: true
            from: 1
            to: 4
            value: cfg_FanCount.valueOf()
            Layout.columnSpan: 2
        }


        // ___________________row 4
        Label {
            text: qsTr(" T° :")
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignBottom
            Layout.fillWidth: true
            Layout.fillHeight: true
            font.pixelSize: fontSize12
            Layout.columnSpan: 1
        }
        Label {
            text: qsTr("Bed :")
            verticalAlignment: Text.AlignBottom
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
            Layout.fillHeight: false
            font.pixelSize: fontSize12
            Layout.columnSpan: 2
        }


        Label {
            text: qsTr("Ext :")
            verticalAlignment: Text.AlignBottom
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
            Layout.fillHeight: false
            font.pixelSize: fontSize12
            Layout.columnSpan: 2
        }

        Label {
            text: qsTr("Protection :")
            verticalAlignment: Text.AlignBottom
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
            Layout.fillHeight: false
            font.pixelSize: fontSize12
            Layout.columnSpan: 2
        }
        // ___________________row 5
        Label {
            text: qsTr("PLA :")
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
            Layout.fillWidth: true
            Layout.fillHeight: true
            font.pixelSize: fontSize12
            Layout.columnSpan: 1
        }

        SpinBox {
            id: sb_BedPLA
            enabled: cb_HeatBed.checked
            Layout.fillWidth: true
            font.pixelSize: fontSize12
            font.bold: true
            from: 0
            to: cfg_MaxBedTemp
            value: cfg_BedPLA
            Layout.columnSpan: 2
        }
        SpinBox {
            id: sb_ExtPLA
            Layout.fillWidth: true
            font.pixelSize: fontSize12
            font.bold: true
            from: 0
            to: cfg_MaxExtTemp
            value: cfg_ExtPLA
            Layout.columnSpan: 2
        }

        SpinBox {
            id: sb_ExtProt
            Layout.fillWidth: true
            font.pixelSize: fontSize12
            font.bold: true
            from: 0
            to: cfg_MaxExtTemp
            value: cfg_ExtProt
            Layout.columnSpan: 2
        }

        // _________________________________row 5

        Label {
            text: qsTr("ABS :")
            horizontalAlignment: Text.AlignRight
            Layout.fillWidth: true
            Layout.fillHeight: false
            font.pixelSize: fontSize12
            Layout.columnSpan: 1
        }

        SpinBox {
            id: sb_BedABS
            enabled:  cb_HeatBed.checked
            Layout.fillWidth: true
            font.pixelSize: fontSize12
            font.bold: true
            from: 0
            to: cfg_MaxBedTemp
            value: cfg_BedABS
            Layout.columnSpan: 2
        }


        SpinBox {
            id: sb_ExtABS
            Layout.fillWidth: true
            font.pixelSize: fontSize12
            font.bold: true
            from: 0
            to: cfg_MaxExtTemp
            value: cfg_ExtABS
            Layout.columnSpan: 2
        }

        // _______________________row 6







        Button {
            id : btnInfo
            text : qsTr("Info")
            checked :false
            checkable: false
            font.pixelSize: fontSize14
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.column : 4
            Layout.columnSpan: 1
            Layout.row : 6
            onClicked:  {
                popdialog.show("Info","You must have access in RW on path and file /etc/thing-printer/atcore-bbk.conf")
            }
        }


        Button {
            id : btnConnect
            text : atcore.state>1?qsTr("Disconnect"):qsTr("Connect")
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            checked :atcore.state>1?true:false
            checkable: false
            font.pixelSize: fontSize14
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.column : 6
            Layout.columnSpan: 2
            Layout.row : 6

            onClicked:  {
                cfg_Device = cb_Device.editText;
                cfg_Firmware =cb_Firmware.editText;
                cfg_PortSpeed = cb_PortSpeed.editText;
                cfg_HeatBed = cb_HeatBed.checked;
                cfg_BedPLA =  sb_BedPLA.value;
                cfg_ExtPLA =  sb_ExtPLA.value;
                cfg_BedABS =  sb_BedABS.value;
                cfg_ExtABS =  sb_ExtABS.value;
                cfg_ExtProt = sb_ExtProt.value;
                cfg_FanCount = sb_FanCount.value;
                cfg_ExtCount = sb_ExtCount.value;
                cfg_FeedRateXY = sb_FeedRateXY.value;
                cfg_FeedRateZ = sb_FeedRateZ.value;
                cfg_FeedRateE = sb_FeedRateE.value;
                if (atcore.state>1) {
                    atcore.closeConnection();
                }else{
                    mainpage.init();
                }
            }

        }

    }



    function init(){
        cb_Device.model=atcore.serialPorts;
        if (cb_Device.find(cfg_Device)>0) {
            cb_Device.currentIndex=cb_Device.find(cfg_Device.toString()) ;
        }
        cb_Device.editText =  cfg_Device;

        cb_Firmware.model=atcore.availableFirmwarePlugins;
        if (cb_Firmware.find(cfg_Firmware)>0) {
            cb_Firmware.currentIndex=cb_Firmware.find(cfg_Firmware.toString()) ;
        }
        cb_Firmware.editText=cfg_Firmware;

        cb_PortSpeed.model=atcore.portSpeeds;
        if (cb_PortSpeed.find(cfg_PortSpeed.toString())>0) {
            cb_PortSpeed.currentIndex=cb_PortSpeed.find(cfg_PortSpeed.toString()) ;
        }
        cb_PortSpeed.editText=cfg_PortSpeed.toString();
    }

}
