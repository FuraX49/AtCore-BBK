import QtQuick 2.11
import QtQuick.Controls 2.4


MenuItem  {
    font.pointSize: fontSize16
    text: qsTr("System")
    icon {
        source: "qrc:/Images/menu/SettingsIcon.png"
        height: font.fontSize16*2
        width : font.fontSize16*2
    }
}
