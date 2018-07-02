import QtQuick 2.11
import QtQuick.Window 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11


PaneBorder {
    id: paneBorder
    implicitWidth: 150
    implicitHeight: 50
    property alias textRole: comboBox.textRole
    property alias model  : comboBox.model
    property alias text  : button.text
    property alias macros : lmMacros
    padding: 2

    signal execClicked (string macro)
    

    Button {
        id: button
        text: qsTr("Exec")
        flat: false
        anchors.margins: 0
        anchors.bottom: parent.bottom
        anchors.top: parent.top
        anchors.left: parent.left
        width : parent.width * 0.35
        onClicked: {
            execClicked(comboBox.currentText);
        }
    }

    ComboBox {
        id: comboBox
        anchors.margins: 0
        anchors.left: button.right
        anchors.leftMargin: 2
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: parent.top
        model:  ListModel {
            id : lmMacros
            ListElement { text: "G28" }
        }
    }

}
