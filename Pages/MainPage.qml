import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Window 2.11
import QtQuick.Layouts 1.11
import QtQuick.VirtualKeyboard 2.3
import QtQml 2.11
import QtTest 1.11
import Qt.labs.settings 1.0

import "../Components/"
import "../Components/ParseMsg.js" as PM
import "../Components/JobState.js" as JS
import "../Plugins"

import QlFiles 1.0
import QtWebSockets 1.0
import org.kde.atcore 1.0
import Process 1.0


Page  {
    id : mainpage
    visible: true
    width: 800
    height: 480

    property alias tbPrint : tbPrint;
    property alias tbPause : tbPause;
    property alias tbCancel : tbCancel;
    property alias popdialog : popdialog
    property alias tbEmergency : tbEmergency;

    // Based on Minimal Height of 480
    property int fontSize10 : Math.round(height / 48 );
    property int fontSize12 : Math.round(height / 40 );
    property int fontSize14 : Math.round(height / 34 );
    property int fontSize16 : Math.round(height / 30 );
    property int fontSize20 : Math.round(height / 24 );
    property int fontSize24 : Math.round(height / 20 );
    property int fontSize30 : Math.round(height / 16 );



    // ************ SETTINGS ***************************************
    property string cfg_Device : "testing_1"
    property string cfg_Firmware :  "redeem"
    property string cfg_PortSpeed :  "115200"
    property bool  cfg_LogOk :  false
    property bool  cfg_LogInfo:  false
    property int  cfg_FanCount :  1
    property int  cfg_FeedRateXY :  2000
    property int  cfg_FeedRateZ :  1000
    property int  cfg_FeedRateE :  200
    property string  cfg_PathModels :  "file:///usr/share/models"
    property bool cfg_SdCard: false
    property string cfg_Macros : ""

    // Extruder
    property int  cfg_ExtCount :  1
    property int  cfg_ExtABS :  220
    property int  cfg_ExtPLA :  170
    property int  cfg_BedABS :  70
    property int  cfg_BedPLA :  50
    property int  cfg_ExtProt: cfg_ExtPLA-20
    property int  cfg_MaxBedTemp: 120
    property int  cfg_MaxExtTemp: 300


    // Bed
    property bool  cfg_HeatBed :false
    property int cfg_BedWidth : 200
    property int cfg_BedDepth : 200
    // property int cfg_BedHeight : 100

    // Web
    property bool cfg_WebActive: false
    property int cfg_WebPort:  5005


    Settings {
        id: printerSettings
        category : "Printer"
        property alias device : mainpage.cfg_Device
        property alias firmware: mainpage.cfg_Firmware
        property alias portspeed: mainpage.cfg_PortSpeed
        property alias logok: mainpage.cfg_LogOk
        property alias loginfo:mainpage.cfg_LogInfo
        property alias fancount: mainpage.cfg_FanCount
        property alias feedRateXY : mainpage.cfg_FeedRateXY
        property alias feedRateZ :  mainpage.cfg_FeedRateZ
        property alias feedRateE :  mainpage.cfg_FeedRateE
        property alias pathmodels: mainpage.cfg_PathModels
        property alias sdcard: mainpage.cfg_SdCard
        property alias macros: mainpage.cfg_Macros
    }

    Settings {
        id: extruderSettings
        category : "Extruder"
        property alias extcount: mainpage.cfg_ExtCount
        property alias extabs :  mainpage.cfg_ExtABS
        property alias extpla : mainpage.cfg_ExtPLA
        property alias bedabs : mainpage.cfg_BedABS
        property alias bedpla : mainpage.cfg_BedPLA
        property alias extprot: mainpage.cfg_ExtProt
        property alias maxbedtemp : mainpage.cfg_MaxBedTemp
        property alias maxexttemp : mainpage.cfg_MaxExtTemp
    }

    Settings {
        id: windowSettings
        category : "Window"
        property alias width: mainpage.width
        property alias height: mainpage.height
    }

    Settings {
        id: webSettings
        category : "Web"
        property alias active: mainpage.cfg_WebActive
        property alias port: mainpage.cfg_WebPort
    }

    Settings {
        id: bedSettings
        category : "Bed"
        property alias heatbed: mainpage.cfg_HeatBed
        property alias width : mainpage.cfg_BedWidth
        //        property alias height: mainpage.cfg_BedHeight
        property alias depth : mainpage.cfg_BedDepth
    }

    Process {
        id: process
        onReadyRead: console.log(readAll());
    }


    // ************ AtCore ***************
    SignalSpy {
        id: spyAtCore
        function raz(SignalName) {
            spyAtCore.clear();
            spyAtCore.signalName= SignalName;
            return valid;
        }
        target: atcore
    }

    AtCore {
        id: atcore

        onReceivedMessage: {
            try {
                PM.strmsg=message.toString();
                //PM.strmsg=message.replace(/(\r\n\t|\n|\r\t)/gm," ").toString();
                // console.log(smsg);
                if (PM.testOk()) {
                    if (cfg_LogOk) {
                        terminal.appmsg(PM.strmsg);
                    }
                    if (PM.testM105()) {
                        printpage.updateHeater(PM.TempHeaters);

                        tempchart.addTemps(0,PM.TempHeaters.E0,PM.TempHeaters.TargetE0);
                        if (cfg_HeatBed) tempchart.addTemps(1,PM.TempHeaters.Bed,PM.TempHeaters.TargetBed);
                        if (cfg_ExtCount>1) tempchart.addTemps(2,PM.TempHeaters.E1,PM.TempHeaters.TargetE1);
                        if (cfg_ExtCount>2) tempchart.addTemps(3,PM.TempHeaters.E2,PM.TempHeaters.TargetE2);
                        if (cfg_ExtCount>3) tempchart.addTemps(4,PM.TempHeaters.E3,PM.TempHeaters.TargetE3);
                        return true;
                    }

                    if (PM.testM114()) {
                        jog.updatePos(PM.AxesPos);
                        return true;
                    }


                    if (PM.testM119()) {
                        jog.updateES(PM.EndStop);
                        return true;
                    }
                    return false;
                } else {

                    if (cfg_LogInfo) {
                        terminal.appmsg(PM.strmsg);
                    }
                    // M20 detect BEGIN_FILE_LIST
                    if (PM.testBeginFile()) {
                        busy.anim(true);
                        filessd.clearFileList();
                        return true;
                    }

                    // M20 if in File list detect a FILE_LIST or END_FILE_LIST
                    if (PM.FileList) {
                        if (PM.testEndFile())  {
                            busy.anim(false);
                            return true;
                        } else {
                            if (PM.testFileDesc()) {
                                if (PM.isGcodeFile()) {
                                    filessd.addFileDesc(PM.FileDesc);
                                }
                                return true;
                            }
                        }
                    }


                    if (PM.testSDPrinting()) {
                        if (cfg_LogInfo) terminal.appmsg(PM.strmsg);
                        return true;
                    }

                    // Bed Level
                    if (PM.testM561()) {
                        if (cfg_LogInfo) terminal.appmsg("Reset list bed probe point.");
                        return true;
                    }

                    if (PM.testG30()) {
                        if (cfg_LogInfo) terminal.appmsg("Add bed probe point.");
                        return true;
                    }

                    if (PM.testM561_S() ) {
                        if (cfg_LogInfo)  terminal.appmsg("Bed matrix visible ");
                        return true;
                    }
                    return false;

                }
            }
            catch (E) {
                console.log("Error parsing message on :" + PM.strmsg);
            }

        }


        onStateChanged: {
            switch(state) {
            case  AtCore.DISCONNECTED :
                console.log("atcore DISCONNECTED ");
                JS.JobState.connected=false;
                JS.JobState.state="DISCONNECTED";
                break;

            case  AtCore.CONNECTING :
                console.log("atcore  CONNECTING");
                JS.JobState.state="CONNECTING";
                break;

            case  AtCore.IDLE :
                console.log("atcore  IDLE");
                JS.JobState.connected=true;
                JS.JobState.state="IDLE";
                JS.JobState.resume=false;
                break;

            case  AtCore.BUSY :
                console.log("atcore  BUSY");
                JS.JobState.state="BUSY";
                JS.JobState.resume=false;
                break;

            case AtCore.PAUSE :
                console.log("atcore  PAUSE");
                JS.JobState.state="PAUSE";
                JS.JobState.resume=true;
                tbPrint.enabled=false;
                tbPause.enabled=true;
                tbCancel.enabled=true;
                break;

            case AtCore.ERRORSTATE :
                console.log("atcore  ERROR");
                JS.JobState.state="ERROR";
                JS.JobState.error=true;
                break;

            case AtCore.STOP :
                console.log("atcore  STOP");
                JS.JobState.state="STOP";
                JS.JobState.resume=false;
                tbPrint.enabled=true;
                tbPause.enabled=false;
                tbCancel.enabled=false;
                break;

            case AtCore.STARTPRINT :
                console.log("atcore  STARTPRINT " + Date().toLocaleString());
                JS.JobState.state="STARTPRINT";
                JS.JobState.resume=false;
                terminal.appmsg("STARTPRINT " + Date().toLocaleString());
                tbPrint.enabled=false;
                tbPause.enabled=true;
                tbCancel.enabled=true;
                break;

            case AtCore.FINISHEDPRINT :
                console.log("atcore  FINISHEDPRINT " + Date().toLocaleString());
                JS.JobState.state="FINISHEDPRINT";
                JS.JobState.resume=false;
                JS.finishTime();
                terminal.appmsg("FINISHEDPRINT " + Date().toLocaleString());
                tbPrint.enabled=true;
                tbPause.enabled=false;
                tbCancel.enabled=false;
                break;

            default:
                console.log("atcore  DEFAULT error ");
                break;
            }
            lbState.text=JS.JobState.state;
            JS.JobState.print=tbPrint.enabled;
            JS.JobState.pause=tbPause.enabled;
            JS.JobState.cancel=tbCancel.enabled;
        }

        onPrintProgressChanged: {
            JS.updateTime(newProgress);
            printpage.printprogress.updateProgress(JS.JobProgress);
        }
        /* Not used because not FileSize
        onSdCardFileListChanged:  {
            filessd.clearFileList();
            filessd.filesModel.append(fileList);
        } */
    }





    // ************ Menu *****************
    Menu {
        id: rootMenu
        implicitWidth : fontSize14 * 16
        cascade: true

        MenuIconItem  {
            text: qsTr("Print")
            icon { source : "qrc:/Images/menu/print.svg"}
            onTriggered: {
                stackLayout.currentIndex=0
                rootMenu.close()
            }
        }

        MenuIconItem  {
            text: qsTr("Log")
            icon { source: "qrc:/Images/menu/log.svg" }
            onTriggered: {
                stackLayout.currentIndex = 1
                rootMenu.close()
            }
        }

        MenuIconItem  {
            text: qsTr("Chart")
            icon {
                source: "qrc:/Images/menu/graphs.svg"
            }
            onTriggered: {
                stackLayout.currentIndex = 2
                rootMenu.close()
            }
        }

        MenuIconItem  {
            text: qsTr("Files")
            enabled: !cfg_SdCard
            visible: !cfg_SdCard
            implicitHeight: !cfg_SdCard?fontSize30*2:0
            icon { source: "qrc:/Images/menu/files.svg" }
            onTriggered: {
                stackLayout.currentIndex = 3
                rootMenu.close()
            }
        }

        MenuIconItem  {
            text: qsTr("SD Files")
            enabled: cfg_SdCard
            visible: cfg_SdCard
            implicitHeight: cfg_SdCard?fontSize30*2:0
            icon { source: "qrc:/Images/menu/files.svg"}
            onTriggered: {
                stackLayout.currentIndex = 4
                rootMenu.close()
            }
        }
        MenuIconItem  {
            text: qsTr("Jog")
            icon { source: "qrc:/Images/menu/jog.svg"}
            onTriggered: {
                stackLayout.currentIndex = 5
                rootMenu.close()
            }
        }
        MenuIconItem {
            text: qsTr("Setting")
            icon { source: "qrc:/Images/menu/settings.svg"}
            onTriggered: {
                stackLayout.currentIndex = 6;
                rootMenu.close();
            }
        }

        MenuSeparator { }
        //************* Action System
        Menu {
            id : systemctlMenu
            cascade : true
            overlap : 100
            title : qsTr("SytemCtl")

            font.pointSize: fontSize14

            SystemAction {
                text: "restart REDEEM"
                parameters : ["restart redeem"]
                onTriggered: process.start(program,parameters)
            }
            MenuSeparator { }

            SystemAction {
                text: "restart ATCORE-BBK"
                parameters : ["restart atcore"]
                onTriggered: process.start(program,parameters)
            }
            MenuSeparator { }

            SystemAction {
                text: "stop MJPG"
                parameters : ["stop mjpg"]
                onTriggered: process.start(program,parameters)
            }

            SystemAction {
                text: "start MJPG"
                parameters : ["start mjpg"]
                onTriggered: process.start(program,parameters)
            }
            MenuSeparator { }

            SystemAction {
                id: actionReboot
                text: "REBOOT"
                program : "/sbin/reboot"
                parameters : []
                onTriggered: process.start(program,parameters)
            }
            MenuSeparator { }
            SystemAction {
                id: actionPowerOff
                text: "POWEROFF"
                program : "/sbin/poweroff"
                parameters : []
                onTriggered: process.start(program,parameters)
                icon.source : "qrc:/Images/menu/system.svg"            }
        }


    }


    // ********  header ToolBar **********************
    header: ToolBar {
        id: headtoolbar
        z : 99
        contentHeight: fontSize24 *2
        anchors.margins: 0
        spacing: 0
        padding: 0

        RowLayout {
            anchors.fill: parent
            spacing: 0
            anchors.margins: 0
            HeaderButton {
                id : tbMenu
                text: "Menu"
                enabled: true
                icon {
                    source : "qrc:/Images/header/menu.svg"
                }
                onClicked: {
                    rootMenu.open();
                }

            }
            HeaderButton {
                id :tbPrint
                text: "Print"
                enabled: false
                icon {
                    source : "qrc:/Images/header/play_circle_filled.svg"
                }
                onClicked: {
                    if (JS.JobFile.fileselected) {
                        JS.initTime();
                        JS.JobState.resume=false;
                        atcore.print(JS.JobFile.name,cfg_SdCard);
                    }
                }
            }

            HeaderButton {
                id :tbPause
                text: "Pause"
                enabled: false
                checkable: true
                checked : JS.JobState.resume;
                icon {
                    source : "qrc:/Images/header/pause_circle_filled.svg"
                }
                onClicked: {
                    if ((JS.JobState.resume===false)) {
                        // ask PAUSE
                        text = "Resume";
                        atcore.pause("M114");
                        terminal.appmsg("PAUSE PRINT")

                    } else {
                        // ask RESUME
                        text = "Pause";
                        atcore.resume();
                        terminal.appmsg("RESUME PRINT");
                    }
                }
            }

            HeaderButton {
                id : tbCancel
                text: "Stop"
                enabled: false
                icon {
                    source : "qrc:/Images/header/stop_circle.svg"
                }
                onClicked: {
                    atcore.stop();
                    terminal.appmsg("STOP")
                }
            }

            Label {
                width : fontSize10*9
                enabled: true
                id: lbState
                text: "Connecting"
                color : palette.highlight
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.maximumWidth: fontSize10*9
                Layout.minimumWidth: fontSize10*9
                Layout.preferredWidth: fontSize10*9

            }

            HeaderButton {
                id : tbEmergency
                text: "HALT"
                enabled: true
                icon {
                    source : "qrc:/Images/header/highlight_off.svg"
                }
                onClicked: {
                    atcore.pushCommand("M112");
                    terminal.appmsg("M112")
                }
            }

        }



    }



    // ******** Pages View **********************
    StackLayout {
        id:stackLayout
        anchors.fill: parent
        currentIndex: 0
        Print {id : printpage}
        Console {id : terminal}
        TempCharts{ id : tempchart}

        Files{
            id : files
            onFileChoosed: {
                if (atcore.state<AtCore.BUSY) {
                    if (selected) {
                        tbPrint.enabled =true;
                        JS.JobState.print=true;
                        JS.JobFile.name = fileName;
                        JS.JobFile.origine =fileOrigin;
                        JS.JobFile.size =fileSize;
                        JS.JobFile.date =fileDate;
                        JS.JobFile.fileselected=true;
                    } else {
                        tbPrint.enabled =false;
                        JS.JobState.print=false;
                        JS.JobFile.name = "";
                        JS.JobFile.fileselected=false;
                    }
                    printpage.printprogress.initProgress(JS.JobFile);
                }
            }
        }

        FilesSD{
            id : filessd
            onFileChoosed: {
                if (atcore.state<AtCore.BUSY) {
                    if (selected) {
                        tbPrint.enabled =true;
                        JS.JobState.print=true;
                        JS.JobFile.name = fileName;
                        JS.JobFile.origine =fileOrigin;
                        JS.JobFile.size =fileSize;
                        JS.JobFile.date =fileDate;
                        JS.JobFile.fileselected=true;
                    } else {
                        tbPrint.enabled =false;
                        JS.JobState.print=false;
                        JS.JobFile.name = "";
                        JS.JobFile.fileselected=false;
                    }
                    printpage.printprogress.initProgress(JS.JobFile);
                }
            }
        }

        Jog {id : jog}
        Configs {id : configs}
    }



    // ******** WEB interface **********************
    WebService {
        enabled: cfg_WebActive
    }

    // ******** VirtualKeyboard **********************

    InputPanel {
        id: inputPanel
        z: 99
        x: 0
        y: mainpage.height
        width: mainpage.width

        states: State {
            name: "visible"
            when: inputPanel.active
            PropertyChanges {
                target: inputPanel
                y: mainpage.height - inputPanel.height -25
            }
        }
        transitions: Transition {
            from: ""
            to: "visible"
            reversible: true
            ParallelAnimation {
                NumberAnimation {
                    properties: "y"
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }


    // ***************** 3D Viewer *************************
    // Create 3DViewer in dynamic & "modal"
    // because CPU usage ...



    property var obj3d : undefined

    Loader {
        id : loader3D
        active : true
        asynchronous: true

        onStatusChanged: {
            if (loader3D.status === Loader.Ready) {
                obj3d=loader3D.item;
                busy.anim(false);
            }
        }
    }
    function show3D(page3D) {
        busy.anim(true);
        loader3D.setSource(page3D, {"x": 0, "y": 0, "height": mainpage.width,"height":mainpage.height, "bedwidth" : cfg_BedWidth , "beddepht" : cfg_BedDepth} ) ;
        headtoolbar.visible=false;
    }

    function destroy3D() {
        if (obj3d) {
            obj3d.enabled=false;
            obj3d.visible=false;
        }
        obj3d= undefined
        headtoolbar.visible=true;
    }




    // ********** Error Screen **********
     PopDialog {
        id: popdialog
        parent: mainpage

    }



    // Must be the last too stay visible...
    BusyAnimation {
        id : busy
    }




    function init(){
        busy.anim(true);
        configs.init();
        if (cfg_PortSpeed==="undefined" ) {
            cfg_PortSpeed="115200";
        }
        console.log("init Serial " +  cfg_Device + " at speed " +  cfg_PortSpeed);
        if (atcore.initSerial(cfg_Device,cfg_PortSpeed.valueOf()) && cfg_Device!="undefined") {
            try {
                spyAtCore.raz("stateChanged") ;
                atcore.loadFirmwarePlugin(cfg_Firmware);
                spyAtCore.wait(5000); // wait 5s AtCore change state

                console.log("Wait message from printer" );
                spyAtCore.raz("receivedMessage") ;
                atcore.pushCommand("M110 N0");
                spyAtCore.wait(10000); // wait 10s first message from printer

                terminal.appmsg("AtCore library version :" + atcore.version);

                if (atcore.state===AtCore.IDLE) {
                    printpage.init();
                    terminal.init();
                    tempchart.init();
                    if (cfg_SdCard) {
                        filessd.init();
                    } else {
                        files.init();
                    }
                    jog.init(); // TODO Gcode MACROs
                    atcore.pushCommand("M114");
                    atcore.pushCommand("M119");
                }
            } catch  (Error)  {
                popdialog.show("Configuration Error","Unable to dialog with printer");
                atcore.closeConnection();
                atcore.setState(AtCore.DISCONNECTED);
            }

        } else {
            popdialog.show("Configuration Error","Failed to open serial device  : "+ cfg_Device +" , in r/w mode");
        }
        busy.anim(false);
    }


    // run Animation after all component ready
    Timer {
        id : animstart
        repeat : false
        interval : 1000
        running : false
        triggeredOnStart : false
        onTriggered: {
                mainpage.init();
        }
    }

    Component.onCompleted: {
        animstart.start();
        terminal.appmsg(Qt.application.name + " version :" + Qt.application.version);
    }


    Component.onDestruction: {
        // files.unMountDevice();
        if(atcore.state >= AtCore.IDLE) {
            atcore.closeConnection();
            atcore.setState(AtCore.DISCONNECTED);
        }
    }
}
