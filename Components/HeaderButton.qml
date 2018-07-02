import QtQuick 2.11
import QtQuick.Controls 2.4

ToolButton {
    text: "Menu"
    font.pixelSize: fontSize24
    icon {
        source : ""
        height : Math.round(parent.height *0.8)
        width : Math.round(parent.height *0.8)
    }
}
