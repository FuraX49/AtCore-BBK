import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11

Page {
    id: terminal
    width: 800
    height: 480
    property alias logList: logList
    property alias cbOkLog: cbOkLog
    property alias cbInfoLog: cbInfoLog
    title: qsTr("Terminal")

    function appmsg(msg) {
        mylogmodel.addLogLine(msg);
    }


    RowLayout {
        id : rowlayouttop
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 5
        height : fontSize20 * 2

        TextField {
            id: dataToSend
            Layout.fillHeight: true
            Layout.columnSpan: 4
            font.weight: Font.Bold
            font.bold: false
            font.pixelSize: fontSize12
            Layout.fillWidth: true
            placeholderText:  "Data to send..."

            onAccepted: {
                if (atcore.state>1) {
                    atcore.pushCommand(dataToSend.text);
                    appmsg(dataToSend.text);
                } else {
                    appmsg("Not connected");
                }
            }
        }



        Button {
            id: sendBtn
            text: qsTr("Send")
            Layout.fillHeight: true
            font.pixelSize: fontSize12
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            onClicked: {
                if (atcore.state>1) {
                    atcore.pushCommand(dataToSend.text);
                    appmsg(dataToSend.text);
                } else {
                    appmsg("Not connected");
                }
            }
        }


        CheckBox {
            id: cbOkLog
            text: qsTr("Ok")
            Layout.fillWidth: true
            Layout.fillHeight: true
            font.pixelSize: fontSize20
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            hoverEnabled: false
            focusPolicy: Qt.ClickFocus
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.text: "Disable when print, use too mutch CPU !"
            ToolTip.visible: hovered
            onCheckedChanged: {
                cfg_LogOk = checked;
            }
        }


        CheckBox {
            id: cbInfoLog
            text: qsTr("Info")
            Layout.fillWidth: true
            Layout.fillHeight: true
            font.pixelSize: fontSize20
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            onCheckedChanged: {
                cfg_LogInfo = checked;
            }
        }

    }

    ListView {
          id: logList
          anchors.rightMargin: 5
          anchors.leftMargin: 5
          anchors.bottomMargin: 5
          anchors.topMargin: 10
          boundsBehavior: Flickable.StopAtBounds
          model: mylogmodel.dataList /// Propery exposed from C++
          clip: true
          anchors.bottom: parent.bottom
          anchors.right: parent.right
          anchors.left: parent.left
          anchors.top: rowlayouttop.bottom
          ScrollBar.vertical: ScrollBar {
              active: true
          }
          delegate:
              Text {
              id: textLogs_Id
              text: modelData
              font.pixelSize: fontSize12
              color: terminal.palette.buttonText
              wrapMode: Text.WordWrap
              width: parent.width
          }
      }

      function init(){
          cbInfoLog.checked=cfg_LogInfo;
          cbOkLog.checked=cfg_LogOk;
          // adjust visible lines
          mylogmodel.setlinecount(Math.floor(logList.height/fontSize16)-2);
      }
}
