import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Templates 2.4 as T

T.Pane {
    id: control

    implicitWidth: Math.max(background ? background.implicitWidth : 0, contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0, contentHeight + topPadding + bottomPadding)

    contentWidth: contentItem.implicitWidth || (contentChildren.length === 1 ? contentChildren[0].implicitWidth : 0)
    contentHeight: contentItem.implicitHeight || (contentChildren.length === 1 ? contentChildren[0].implicitHeight : 0)

    padding: 2

    background: Rectangle {
            radius: 4
            color: control.palette.window
            border.width: 2
            border.color: control.palette.buttonText
        }
}
