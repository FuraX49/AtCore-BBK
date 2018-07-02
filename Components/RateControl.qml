import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11

PaneBorder  {
    id: control
    implicitHeight: 50
    implicitWidth: 150

    property string title: "Rate"
    property real maxRate : 300
    property real minRate: 0
    property real currentRate: 100
    property real stepsize : 5

    signal ratechanged (real  speed)


    GridLayout {
        id: gridLayout
        columnSpacing: 0
        rowSpacing: 0
        columns: 5
        anchors.fill: parent
        Slider {
            id: slider
            padding: 0
            Layout.fillWidth: true
            Layout.columnSpan: 4
            Layout.fillHeight: true
            implicitWidth: Math.floor(parent.width * 0.8)
            Layout.margins: 2
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            snapMode: Slider.SnapOnRelease
            orientation: Qt.Horizontal
            value: control.currentRate
            from : control.minRate
            to   : control.maxRate
            stepSize : control.stepsize
            background: Text {
                id: name
                text: slider.value.toString()
                font.weight: Font.Light
                color: control.palette.buttonText
                font.pixelSize: fontSize10
                width : parent.width
                height: parent.height
            }
        }

        Button {
            id: toolButton
            implicitWidth: Math.floor(parent.width * 0.2)
            text: control.title
            rightPadding: 0
            Layout.fillWidth: true
            highlighted: false
            autoRepeat: false
            spacing: 0
            padding: 0
            leftPadding: 0
            Layout.fillHeight: true
            Layout.margins: 2
            font.pixelSize: fontSize10
            onClicked: {
                ratechanged(slider.value);
            }
        }
    }
}
