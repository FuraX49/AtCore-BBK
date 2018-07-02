import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11

PaneBorder {
    id: control
    implicitHeight : 180
    implicitWidth:  70

    property int  tempminimal : 100

    signal extrude(string tools,string length)
    signal retract(string tools,string length)

    function majNbToosl(nb) {
        for (var x = 1; x <nb; x++) {
            lmTools.append({"tool":"E"+x.toString()});
        }
    }

    property var items: ["1", "5", "10","25","50"]
    property int index : 2

    ColumnLayout {
        id: colroot
        anchors.fill: parent
        spacing: 0

        ComboBox {
            id: cbTool
            Layout.maximumHeight: Math.floor(parent.height / 4)
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: 4
            textRole: "tool"
            model: ListModel {
                id: lmTools
                ListElement { tool: "E0" }
            }
        }

        RoundButton {
            id: roundButton1
            text: "\u2191 -"
            spacing: 0
            font.weight: Font.ExtraBold
            padding: 0
            font.bold: true
            font.pixelSize: fontSize16
            Layout.maximumHeight: Math.floor(parent.height / 4)
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: 4
            onClicked: {
//                control.retract(cbTool.currentIndex.toString(),sbLength.items[sbLength.value]);
                  control.retract(cbTool.currentIndex.toString(),sbLength.text);
            }
        }

/*        SpinBox {
            id : sbLength
            editable : false
            focus: true
            inputMethodHints : Qt.ImhNone
            Layout.fillHeight: true
            Layout.fillWidth: true
            font.bold: true
            font.weight: Font.Medium
            font.pixelSize:  fontSize12
            Layout.margins: 0
            property var items: ["1", "5", "10","25","50"]
            from: 0
            to:  items.length -1
            value : 2
            padding: 6
            rightPadding: 0
            leftPadding: 0
            textFromValue: function(value, locale) {
                return Number(items[value]).toLocaleString(locale, 'f', 0);
            }

        }*/
         // Replacement for 5.10.1 SpinBox don't work !!!!?????
         RowLayout {

             Button {
                 Layout.fillHeight: true
                 Layout.fillWidth: true
                 enabled: index>0?true:false
                 text: "-"
                 onClicked: {
                     if (index>0) index--;
                 }
             }
             Label {
                 id : sbLength
                 Layout.fillHeight: true
                 Layout.fillWidth: true
                 Layout.alignment: Qt.AlignHcenter | Qt.AlignVCenter
                 text : items[index]
                 font.bold: true
                 horizontalAlignment: Text.AlignHCenter
                 verticalAlignment: Text.AlignVCenter
             }
             Button {
                 Layout.fillHeight: true
                 Layout.fillWidth: true
                 text: "+"
                 enabled: index<items.length-1
                 onClicked: {
                     if (index<items.length-1) index++;
                 }
             }
         }

        RoundButton {
            id: roundButton
            text: "\u2193 +"
            spacing: 0
            padding: 0
            font.weight: Font.ExtraBold
            font.bold: true
            font.pixelSize:  fontSize16
            Layout.maximumHeight: Math.floor(parent.height / 4)
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: 4
            onClicked: {
                //control.extrude(cbTool.currentIndex.toString(),sbLength.items[sbLength.value]);
                control.extrude(cbTool.currentIndex.toString(),sbLength.text);
            }
        }
    }
}
