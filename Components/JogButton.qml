/****************************************************************************
**
** Copyright (C) 2017 The Qt Company Ltd.
** Contact: http://www.qt.io/licensing/
**
** This file is part of the Qt Quick Controls 2 module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL3$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see http://www.qt.io/terms-conditions. For further
** information use the contact form at http://www.qt.io/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 3 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPLv3 included in the
** packaging of this file. Please review the following information to
** ensure the GNU Lesser General Public License version 3 requirements
** will be met: https://www.gnu.org/licenses/lgpl.html.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 2.0 or later as published by the Free
** Software Foundation and appearing in the file LICENSE.GPL included in
** the packaging of this file. Please review the following information to
** ensure the GNU General Public License version 2.0 requirements will be
** met: http://www.gnu.org/licenses/gpl-2.0.html.
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Controls.impl 2.4
import QtQuick.Templates 2.4 as T

import QtGraphicalEffects 1.0

T.Button {
    id: control
    property bool homebutton: false
    property bool es1: false
    property bool es2: false
    property alias image: image

    font.pixelSize: fontSize30
    font.weight: Font.ExtraBold

    onEs1Changed: {
        esoc.color=Qt.rgba( (es1?1.0:0.0),0.0, (es2?1.0:0.0),1.0);
        esoc.visible=es1||es2;
    }
    onEs2Changed: {
        esoc.color=Qt.rgba( (es1?1.0:0.0),0.0, (es2?1.0:0.0),1.0);
        esoc.visible=es1||es2;
    }

    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                                         + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                                          topPadding + bottomPadding)
    baselineOffset:  contentItem.baselineOffset

    padding: 6
    leftPadding: padding + 2
    rightPadding: padding + 2
    spacing: 6

    contentItem: Text {
            text: control.text
            font: control.font

            color: control.checked || control.highlighted ? control.palette.brightText :
                          control.flat && !control.down ? (control.visualFocus ? control.palette.highlight : control.palette.windowText) : control.palette.buttonText
            anchors.centerIn: background
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

    background: Rectangle {
        implicitWidth: 48
        implicitHeight: 48
         width: parent.width > parent.height ? parent.height : parent.width
        height: width
        radius: homebutton ? width /2 : width / 4
        border.width: control.visualFocus ? 4 : 2

        visible: !control.flat || control.down || control.checked || control.highlighted
        color: Color.blend(control.checked || control.highlighted ? control.palette.dark : control.palette.button,
                                                                    control.palette.mid, control.down ? 0.5 : 0.0)
        border.color: control.palette.buttonText

        Image {
            id: image
            fillMode: Image.PreserveAspectFit
            anchors.centerIn: parent
            opacity: 0.3
            height: control.height -4
            width: control.width -4
            source :homebutton ? "qrc:/Images/jog/home.svg" : "qrc:/Images/jog/down.svg"
        }
        ColorOverlay {
                    id : esoc
                    anchors.fill: image
                    source: image
                    color: Qt.rgba( 0.0,0.0, 0.0,1.0);
                    visible : false
                }

    }
}
