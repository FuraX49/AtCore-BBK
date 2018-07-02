import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11

PaneBorder {
    id : control
    property alias lbfilename: lbfilename
    property alias lbestimated: lbestimated
    property alias lbremaining: lbremaining
    property alias lbfinish: lbfinish

    implicitHeight : 80
    implicitWidth:  200


    function initProgress(file) {
        lbfilename.text=file.name;
        progressBar.value=0;
    }

    function updateProgress(progress) {
        progressBar.value=progress.completion;
        lbestimated.text=progress.estimatedTime;
        lbfinish.text=progress.finishTime;
        lbremaining.text=progress.remainingTime;
    }


    ColumnLayout {
        id: columnLayout
        spacing: 2
        anchors.fill: parent

        Label {
            id: lbfilename
            text: ""
            font.bold: true
            font.pixelSize: fontSize12
            verticalAlignment: Text.AlignVCenter
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        ProgressBar {
            id: progressBar
            padding: 4
            font.pixelSize: fontSize12
            Layout.fillHeight: true
            Layout.fillWidth: true
            value: 0.0
            from : 0
            to : 100

            background: Rectangle {
                width: parent.width
                height: parent.height/4
                color: control.palette.midlight
                radius: 3

            }

            contentItem: Item {
                width:  parent.width
                height: parent.height/4

                Rectangle {
                    width: progressBar.visualPosition * parent.width
                    height: parent.height
                    radius: 2
                    color:  control.palette.dark
                }
                Text {
                    id: name
                    //text: progressBar.value.toPrecision(2).toString() + "%";
                    text: progressBar.value.toLocaleString(Qt.locale("fr_FR"))+ "%";
                    verticalAlignment: Text.AlignVCenter
                    font.weight: Font.Light
                    color: control.palette.buttonText
                    font.pixelSize: fontSize10
                    width : parent.width
                    height: parent.height
                }
            }
        }

        RowLayout {
            id: rowLayout
            spacing: 2
            Layout.fillHeight: true
            Layout.fillWidth: true
            Label {
                id : lbestimated
                text: qsTr("0")
                font.bold: false
                font.pixelSize: fontSize10
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                leftPadding: 5
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
            Label {
                id : lbremaining
                text: qsTr("0")
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.bold: false
                font.pixelSize: fontSize10
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                rightPadding: 5
                leftPadding: 5
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
            Label {
                id : lbfinish
                text: qsTr("0")
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                font.bold: false
                font.pixelSize: fontSize10
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignRight
                rightPadding: 5
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }

    }
}

