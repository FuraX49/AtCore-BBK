import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Window 2.11
import QtQuick.Layouts 1.11
import Qt.labs.folderlistmodel 2.11

import "../Components"

Page {
    id: files
    width: 800
    height: 480
    title: qsTr("Files")
    signal fileChoosed(bool selected,string fileName,string fileOrigin, int fileSize ,string fileDate)
    // Files
    property string nameoffile: ""
    property string originoffile: ""
    property int sizeoffile: 0
    property string dateoffile:  ""

    property bool showFocusHighlight: false

    function updateLabelPath(){
        var path = folderModel.folder.toString();
        path = path.replace(/^(file:\/{3})/,"");
        lbPath.text  = "/" + decodeURIComponent(path);
        fileview.currentIndex=-1;
    }

    function currentFolder() {
        return folderModel.folder;
    }

    function isFolder(fileName) {
        return folderModel.isFolder(folderModel.indexOf(folderModel.folder + "/" + fileName));
    }
    function canMoveUp() {
        return folderModel.folder.toString() !== "file:///";
    }

    function onItemClick(fileName) {
        nameoffile = "";
        if(!isFolder(fileName) && fileName !== ".") {
            nameoffile = fileName;
            return;
        }
        if(fileName === ".." && canMoveUp()) {
            folderModel.folder = folderModel.parentFolder
        } else if(fileName !== ".") {
            if(folderModel.folder.toString() === "file:///") {
                folderModel.folder += fileName
            } else {
                folderModel.folder += "/" + fileName
            }
        }
        fileview.currentIndex=-1;
    }


    Component {
        id: highlight
        Rectangle {
            width: fileview.width
            height:  fontSize12 *2
            color: palette.alternateBase;
            radius: 5
            enabled: fileview.currentIndex>-1 ? true:false
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
                    width: Math.floor(parent.width * 0.60)
                    font.bold: true
                    font.pixelSize: fontSize12
                    text: qsTr("Name")
                }
                Text {
                    id: date
                    font.bold: true
                    font.pixelSize: fontSize12
                    width: Math.floor(parent.width * 0.25)
                    text: qsTr("Date")
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
                    width: parent.width * 0.6
                }
                Text {
                    id : filemodified
                    text: fileModified.toLocaleString("yyyy-MM-dd hh:mm:ss")
                    font.bold: false
                    font.pixelSize: fontSize12
                    color: palette.windowText
                    width: parent.width * 0.25
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
                    sizeoffile=fileSize;
                    dateoffile=fileModified.toLocaleString("yyyy-MM-dd hh:mm:ss");
                    files.onItemClick(filename.text)
                }
            }
        }
    }

    FolderListModel {
        id: folderModel
        showDotAndDotDot: true
        showDirs: true
        showDirsFirst: true
        folder:  cfg_PathModels
        rootFolder: cfg_PathModels
        nameFilters: ["*.gcode", "*.gco","*.stl"]
        onFolderChanged: {
            updateLabelPath();
        }
    }

    ListView {
        id : fileview
        y : 0
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
        model: folderModel
        delegate: filesDelegate
        currentIndex : -1

    }
    Label {
        id: lbPath
        height: fontSize14*2
        text: ".."
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
                    updateLabelPath();
                    if (  nameoffile !== "") {
                        fileChoosed(true,lbPath.text+"/"+nameoffile,originoffile, sizeoffile ,dateoffile);
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
                    folderModel.folder= cfg_PathModels;
                    folderModel.rootFolder= cfg_PathModels;
                    originoffile="local";
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
                    // TOTO shell mount
                    folderModel.folder= "file:///media/usbmem";
                    folderModel.rootFolder= "file:///media/usbmem";
                    originoffile="usb";
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
                    folderModel.folder= "file:///media/sdcard";
                    folderModel.rootFolder= "file:///media/sdcard";
                    originoffile="sdcard";
                    updateLabelPath();
                }
            }

            HeaderButton {
                id: tb3DView
                enabled: false
                //enabled: (atcore.state<atcore.BUSY)?false:true
                icon {
                    source : "qrc:/Images/files/3DViewer.svg"
                }
                text: qsTr("3DView")
                font.pixelSize: fontSize12
                autoExclusive: false
                checkable: false
                onClicked: {
                    create3DViewer(lbPath.text+"/"+nameoffile);
                }
            }


        }
    }


    function init(){
        originoffile="local";
        files.updateLabelPath();
    }

}
