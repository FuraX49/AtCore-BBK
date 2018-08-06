import QtQuick 2.11
import QtQuick.Window 2.11
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import QuickGCode 1.0

import "../../Components"


Popup  {
    id: rootviewer2d
    modal: true
    x : 0
    y : 0
    width: 800
    height: 480
    parent: mainpage

    property alias quickgcode: quickgcode
    property string  gcodefile
    property double  zoomOrg : 1.0
    property variant centerOrg
    property int highestZ: 0

    RowLayout {
        id: rowLayoutTop
        spacing: fontSize24
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        z : 99
        height: fontSize24 * 2



        Button {
            id: tbcenter
            text: qsTr("Center")
            Layout.fillWidth: true
            Layout.fillHeight: true
            onClicked: {
                slZoom.value=zoomOrg;
                bed.scale=slZoom.value;
                flick.resizeContent(bed.width,bed.height,centerOrg);
                flick.returnToBounds();

            }
        }


        SpinBox {
            id: sbLayers
            Layout.columnSpan: 3
            Layout.fillWidth: true
            Layout.fillHeight: true
            font.pointSize: 14
            stepSize: 1
            from: 0
            value: 0
            to : 1
            onToChanged: {
                contentItem.text =  qsTr("%1 / %2").arg(sbLayers.value).arg(sbLayers.to);
            }
            onValueChanged: {
                quickgcode.drawLayer(value);
                contentItem.text =  qsTr("%1 / %2").arg(sbLayers.value).arg(sbLayers.to);
            }
        }


        Slider {
            id: slZoom
            Layout.columnSpan: 5
            font.pointSize: 9
            Layout.fillHeight: true
            Layout.fillWidth: true
            value: zoomOrg
            from : zoomOrg
            to : 20
            onValueChanged: {
                bed.scale=value
            }
        }

        CheckBox {
            id: cpPath
            text: qsTr("Path")
            Layout.fillHeight: true
            Layout.fillWidth: true
            checked: true
            onCheckedChanged: {
                if (checked)
                    quickgcode.pathcolor="blue";
                else
                    quickgcode.pathcolor="transparent";
            }
        }

        CheckBox {
            id: cpExt
            text: qsTr("Ext")
            Layout.fillHeight: true
            Layout.fillWidth: true
            checked: true
            onCheckedChanged: {
                if (checked)
                    quickgcode.extcolor="red";
                else
                    quickgcode.extcolor="transparent";
            }
        }
        Button {
            id: close
            text: qsTr("Close")
            Layout.fillWidth: true
            Layout.fillHeight: true
            onClicked: {
                delete quickgcode;
                rootviewer2d.close();
            }
        }

    }




    Flickable {
        id: flick
        anchors.top: rowLayoutTop.bottom
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: 0
        contentWidth: bed.width * slZoom.to
        contentHeight: bed.height * slZoom.to

        Rectangle {
            id :bed
            width :mainpage.cfg_BedWidth
            height: mainpage.cfg_SquareBed ? mainpage.cfg_BedDepth :  mainpage.cfg_BedWidth
            radius: mainpage.cfg_SquareBed ? 0: mainpage.cfg_BedWidth
            border.color : "green"
            border.width: 1


            QuickGCode {
                id: quickgcode
                nozzlesize: cfg_nozzlesize * parent.scale
                extcolor: cfg_extcolor
                pathcolor: cfg_pathcolor


                onLayercountChanged: {
                    sbLayers.to= layercount;
                    gcodebusy.anim(false);
                }

                onParseFinish: {
                    quickgcode.drawLayer(0);
                    gcodebusy.anim(false);
                }

                onSourceChanged: {
                    gcodebusy.anim(true); // not visible ? !!!
                    parseLayers();
                    sbLayers.from=0;
                    sbLayers.to=0;
                    slZoom.value = zoomOrg;
                    flick.resizeContent(bed.width,bed.height,centerOrg);
                }
            }
        }


        PinchArea {
            id : pincharea
            anchors.fill: parent
            pinch.target: bed
            pinch.minimumScale: 0.1
            pinch.maximumScale: 20
            pinch.dragAxis: Pinch.XAndYAxis
            property real zRestore: 0
            onSmartZoom: {
                if (pinch.scale > 0) {
                    bed.rotation = 270;
                    bed.scale = Math.min(flick.width, flick.height) / Math.max(bed.bedwidth,bed.bedheight ) * 0.85
                    bed.x = flick.contentX + (flick.width - bed.width) / 2
                    bed.y = flick.contentY + (flick.height - bed.height) / 2
                    zRestore = bed.z
                    bed.z = ++rootviewer2d.highestZ;
                } else {
                    bed.rotation = pinch.previousAngle
                    bed.scale = pinch.previousScale
                    bed.x = pinch.previousCenter.x - bed.width / 2
                    bed.y = pinch.previousCenter.y - bed.height / 2
                    bed.z = zRestore
                    --rootviewer2d.highestZ
                }
            }

            MouseArea {
                id: dragArea
                hoverEnabled: true
                anchors.fill: parent
                drag.target: bed
                scrollGestureEnabled: false
                onPressed: {
                    bed.z = ++rootviewer2d.highestZ;

                }


                onWheel: {
                    if (wheel.modifiers & Qt.ControlModifier) {
                        bed.rotation += wheel.angleDelta.y / 120 * 5;
                        if (Math.abs(bed.rotation) < 4)
                            bed.rotation = 0;
                    } else {
                        bed.rotation += wheel.angleDelta.x / 120;
                        if (Math.abs(bed.rotation) < 0.6)
                            bed.rotation = 0;
                        var scaleBefore = bed.scale;
                        bed.scale += bed.scale * wheel.angleDelta.y / 120 / 10;
                    }
                }
            }

        }

    }

    BusyAnimation {
        id : gcodebusy

    }


    Component.onCompleted: {
        // Calc Zoom
        zoomOrg = Math.min(flick.width/bed.width,flick.height/bed.height);
        slZoom.value = zoomOrg;
        bed.scale=slZoom.value;
        centerOrg = Qt.point(flick.width/2,flick.height/2);
        flick.resizeContent(bed.width,bed.height,centerOrg);

    }


}










