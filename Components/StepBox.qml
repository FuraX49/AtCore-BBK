import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11

SpinBox {
    id: control
    property string jogsize: items[0]
    anchors.margins: 4
    from: 0
    value: 0
    to:  items.length -1

    property int decimals: 1
    property real realValue: value / 10
    property var items: ["0.1", "0.5", "1","5","10","50"]
    padding: 5
    textFromValue: function(value, locale) {
        jogsize=items[value];
        return Number(items[value]).toLocaleString(locale, 'f', control.decimals);
    }

    background: Rectangle {
        radius: 4
        color: control.palette.button
        border.width: 2
        border.color: control.palette.buttonText
    }
}
