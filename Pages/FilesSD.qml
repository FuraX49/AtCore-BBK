import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Window 2.11
import QtQuick.Layouts 1.11


import org.kde.atcore 1.0
import "../Components"
import "../Plugins/QuickGCode"


Page {
    id: filessd

    title: qsTr("Files")

    signal fileChoosed(bool selected,string fileName,string fileOrigin, int fileSize ,string fileDate)
    property alias filesModel: filesModel
    property string nameoffile: ""
    property string originoffile: "/lcl"
    property int sizeoffile: 0
    property string dateoffile:  ""
    property bool showFocusHighlight: false

    function updateLabelPath(){
        filesModel.clear();
        fileview.currentIndex=-1;
        atcore.pushCommand("M21 "+ originoffile);
        atcore.pushCommand("M20 "+ originoffile);
    }

    function addFileDesc(desc) {
        filesModel.append({"fileName": desc.fileName, "fileSize": desc.fileSize});
    }

    function clearFileList() {
        filesModel.clear();
    }

    ListModel {
        id: filesModel
        dynamicRoles: false
        ListElement { fileName: "Ant"; fileSize: "12523" }
        ListElement { fileName: "Flea"; fileSize: "4646" }
        ListElement { fileName: "Parrot"; fileSize: "985433" }
        ListElement { fileName: "Parrot"; fileSize: "985433" }
        ListElement { fileName: "Parrot"; fileSize: "985433" }
        ListElement { fileName: "Parrot"; fileSize: "985433" }
    }

    Component {
        id: highlight
        Rectangle {
            width: fileview.width
            height:  fontSize12 *2
            color: palette.highlight;
            radius: 5
            y: fileview.currentIndex>-1 ?fileview.currentItem.y : 0
            Behavior on y {
                SpringAnimation {
                    spring: 3
                    damping: 0.2
                }
            }
        }
    }



    Component {
        id : colHeader
        Rectangle {
            anchors { left: parent.left; right: parent.right }
            height:  Math.floor(rowheader.implicitHeight * 1.5)
            border.width: 2
            radius: 2
            Row  {
                id : rowheader
                anchors { fill: parent; margins: 2 }
                Text {
                    id: name
                    width: Math.floor(parent.width * 0.85)
                    font.bold: true
                    font.pixelSize: fontSize12
                    text: qsTr("Name")
                }

                Text {
                    id: size
                    font.bold: true
                    font.pixelSize: fontSize12
                    width: Math.floor(parent.width * 0.15)
                    text: qsTr("Size")
                }
            }
        }
    }

    Component {
        id : filesDelegate
        Item {
            id:  wrappper
            anchors { left: parent.left; right: parent.right }
            height : fontSize12 *2

            Row {
                id :rowdelegate
                anchors { fill: parent; margins: 2 }
                Text {
                    id : filename
                    text: fileName
                    font.bold: false
                    font.pixelSize: fontSize12
                    color: palette.windowText
                    width: parent.width * 0.85
                }

                Text {
                    id : filesize
                    text: Math.round(fileSize/1024) +"Kb"
                    font.bold: false
                    font.pixelSize: fontSize12
                    color: palette.windowText
                    width: parent.width * 0.15
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked:{
                    wrappper.ListView.view.currentIndex = index;
                    nameoffile=filename.text;
                    sizeoffile=fileSize;
                }
            }
        }
    }


    ListView {
        id : fileview
        height: 400
        anchors.bottomMargin: 10
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: lbPath.top
        anchors.left: parent.left
        anchors.topMargin: 10
        anchors.margins: 10
        flickableDirection: Flickable.AutoFlickDirection
        highlight: highlight
        highlightFollowsCurrentItem: false
        focus: true
        header: colHeader
        headerPositioning  : ListView.InlineHeader
        model: filesModel
        delegate: filesDelegate

    }
    Label {
        id: lbPath
        height: fontSize14*2
        text: nameoffile
        font.italic: true
        font.pixelSize:fontSize14
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom:  parent.bottom
        anchors.margins: 10
    }


    footer:ToolBar {
        id: toolBar
        contentHeight: fontSize20 *2
        anchors.margins: 0
        spacing: 0
        padding: 0

        RowLayout {
            id: rowLayout
            spacing: 0
            anchors.fill: parent
            anchors.margins: 0

            HeaderButton {
                id: tbSelect
                text: qsTr("Select")
                autoExclusive: false
                icon {
                    source:"qrc:/Images/files/checked.svg"
                }
                font.pixelSize: fontSize12
                checked: false
                checkable: false
                onClicked: {

                    if (  nameoffile !== "") {
                        fileChoosed(true,nameoffile,originoffile, sizeoffile ,dateoffile);
                    } else {
                        fileChoosed(false,"",0,0,0);
                    }
                }
            }


            HeaderButton {
                id: tbLocal
                icon {
                    source: "qrc:/Images/files/Local.svg"
                }
                text: qsTr("Local")
                autoExclusive: true
                font.pixelSize: fontSize12
                checked: true
                checkable: true
                onClicked: {
                    originoffile="/lcl";
                    updateLabelPath();
                }
            }

            HeaderButton {
                id: tbUsb
                icon {
                    source: "qrc:/Images/files/usb.svg"
                }
                text: qsTr("Usb")
                autoExclusive: true
                checkable: true
                font.pixelSize: fontSize12
                onClicked: {
                    originoffile="/usb";
                    updateLabelPath();
                }
            }
            HeaderButton {
                id: tbSDCard
                icon {
                    source: "qrc:/Images/files/sdcard.svg"
                }
                text: qsTr("SDCard")
                font.pixelSize: fontSize12
                autoExclusive: true
                checkable: true
                onClicked: {
                    // TOTO shell mount
                    originoffile="/sd";
                    updateLabelPath();
                }
            }

            HeaderButton {
                id: tb3DView
                enabled: false
                visible: false
                //enabled: (atcore.state<atcore.BUSY)?false:true
                icon {
                    source : "qrc:/Images/files/2DViewer.svg"
                }
                text: qsTr("2D View")
                font.pixelSize: fontSize12
                autoExclusive: false
                checkable: false
                onClicked: {
                    gcodeviewer.open();
                    gcodeviewer.quickgcode.source=lbPath.text+"/"+nameoffile;
                }
            }


        }
    }


    GCodeViewer {
        id : gcodeviewer
        width : mainpage.width
        height: mainpage.height
    }

    function init(){
        originoffile="/lcl";
        updateLabelPath();
    }
}

