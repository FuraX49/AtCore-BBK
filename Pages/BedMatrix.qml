import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11
import QtDataVisualization 1.2
import QtQml 2.11

import "../Components/ParseMsg.js" as PM

Popup {
    id: viewMatrix
    x : 0
    y : 0
    width: mainpage.width
    height: mainpage.height
    parent: mainpage

    property real  bedwidth : 280.0
    property real  beddepht : 180.0
    property real  minprob  : -1.0
    property real  maxprob  : 1.0

    Rectangle {

        anchors.fill: parent
        color: surfaceGraph.theme.windowColor

        function addMatrix(){
            matrixData.clear();
            if (PM.ProbeMatrix.length >0) {
                minprob  = +100.0;
                maxprob  = -100.0;
                for (var i = 0; i < PM.ProbeMatrix.length; i++) {
                    matrixData.append({"mx": PM.ProbeMatrix[i].X, "my": PM.ProbeMatrix[i].Y, "mz" : PM.ProbeMatrix[i].Z});
                    if(PM.ProbeMatrix[i].Z> maxprob) maxprob =PM.ProbeMatrix[i].Z;
                    if(PM.ProbeMatrix[i].Z< minprob) minprob =PM.ProbeMatrix[i].Z;
                }
                var diff = Math.min(Math.abs(maxprob - minprob),0.5);
                var  incgradient = Math.min(0.5-diff ,0.4999);
                mingradient.position=0.5-incgradient;
                maxgradient.position=0.5+incgradient;
                yAxis.min =  minprob  ;
                yAxis.max = maxprob  ;
                surfaceGraph.update();
                scatterGraph.update();
            }  else {
                popdialog.show("BED MATRIX","You must run G29 macro before display")
            }
        }

        ListModel {
            id: matrixData
            ListElement{  mx: 000; my: 000; mz: -0.1; }
            ListElement{  mx: 000; my: 100; mz: -0.1; }
            ListElement{  mx: 000; my: 200; mz: -0.1; }

            ListElement{  mx: 100; my: 000; mz: 0.0; }
            ListElement{  mx: 100; my: 100; mz: 0.0; }
            ListElement{  mx: 100; my: 200; mz: 0.0; }

            ListElement{  mx: 200; my: 000; mz: 0.1; }
            ListElement{  mx: 200; my: 100; mz: 0.1; }
            ListElement{  mx: 200; my: 200; mz: 0.1; }
        }



        Item {
            id: surfaceView
            width: viewMatrix.width
            height: viewMatrix.height
            anchors.top: viewMatrix.top
            anchors.left: viewMatrix.left

            ColorGradient {
                id: surfaceGradient
                ColorGradientStop { id: mingradient; position: 0.00; color: "red" }
                ColorGradientStop { id: midgradient; position: 0.50; color: "blue" }
                ColorGradientStop { id :maxgradient; position: 1.00; color: "red" }
            }

            ValueAxis3D {
                id: xAxis
                labelFormat: "%i mm"
                title: "X Width"
                min : 0
                max : bedwidth
                segmentCount: 6
                titleVisible: true
                titleFixed: false
            }


            ValueAxis3D {
                id: zAxis
                labelFormat: "%i mm"
                title: "Y Depth"
                min : 0
                max : beddepht
                segmentCount: 6
                titleVisible: true
                titleFixed: false
            }

            ValueAxis3D {
                id: yAxis
                labelFormat: "%.3f"
                title: "Z Offset"
                titleVisible: true
                labelAutoRotation: 0
                titleFixed: false
            }


            Surface3D {
                id: surfaceGraph
                visible : true
                width: surfaceView.width
                height: surfaceView.height
                polar: false
                flipHorizontalGrid: false
                horizontalAspectRatio: 0.0
                aspectRatio: 2.0
                selectionMode: AbstractGraph3D.ElementSeries
                shadowQuality: AbstractGraph3D.ShadowQualityNone //ShadowQualitySoftLow

                scene.activeCamera.cameraPreset: Camera3D.CameraPresetIsometricLeftHigh

                theme: Theme3D {
                    type: Theme3D.ThemeRetro  // ThemeIsabelle //ThemeEbony //ThemeRetro // ThemeStoneMoss // ThemeDigia
                    font.pointSize: fontSize20
                }
                axisX: xAxis
                axisY: yAxis
                axisZ: zAxis

                Surface3DSeries {
                    id: surfaceSeries
                    name: "BedMatrix"
                    drawMode: Surface3DSeries.DrawSurfaceAndWireframe // DrawSurface
                    baseGradient: surfaceGradient
                    colorStyle: Theme3D.ColorStyleObjectGradient // ColorStyleRangeGradient
                    itemLabelFormat: " Offset : @yLabel (at @xLabel, @zLabel)"
                    ItemModelSurfaceDataProxy {
                        itemModel: matrixData
                        rowRole: "mx"
                        columnRole: "my"
                        xPosRole: "mx"
                        zPosRole: "my"
                        yPosRole: "mz"
                    }
                }

            }

            Scatter3D {
                id: scatterGraph
                visible : false
                width: surfaceView.width
                height: surfaceView.height
                polar: false
                horizontalAspectRatio: 0.0
                aspectRatio: 2.0
                selectionMode: AbstractGraph3D.ElementSeries
                shadowQuality: AbstractGraph3D.ShadowQualityNone //ShadowQualitySoftMedium
                scene.activeCamera.cameraPreset: Camera3D.CameraPresetIsometricLeftHigh

                theme: Theme3D {
                    type: Theme3D.ThemeRetro
                    font.pointSize: fontSize20
                }
                axisX: xAxis
                axisY: yAxis
                axisZ: zAxis

                Scatter3DSeries {
                    colorStyle: Theme3D.ColorStyleRangeGradient
                    itemLabelFormat: " Offset : @yLabel (at @xLabel, @zLabel)"
                    mesh: Abstract3DSeries.MeshMinimal
                    ItemModelScatterDataProxy {
                        itemModel: matrixData
                        xPosRole: "mx"
                        yPosRole: "mz"
                        zPosRole: "my"
                    }
                }
            }
        }
        RowLayout {
            id: buttonLayout
            Layout.minimumHeight: plotChange.height
            width: parent.width
            anchors.left: parent.left
            spacing: 10
            anchors.margins: 10

            Button {
                id: plotChange
                Layout.fillHeight: true
                Layout.fillWidth: true
                text: "Scatter"
                onClicked: {
                    // TODO selectedElement;
                    if ( surfaceGraph.visible) {
                        scatterGraph.scene.activeCamera.zoomLevel =  surfaceGraph.scene.activeCamera.zoomLevel;
                        scatterGraph.scene.activeCamera.xRotation =  surfaceGraph.scene.activeCamera.xRotation;
                        scatterGraph.scene.activeCamera.yRotation =  surfaceGraph.scene.activeCamera.yRotation;
                        surfaceGraph.visible = false;
                        scatterGraph.visible = true;
                        plotChange.text="Surface";
                    } else {
                        surfaceGraph.scene.activeCamera.zoomLevel =  scatterGraph.scene.activeCamera.zoomLevel;
                        surfaceGraph.scene.activeCamera.xRotation =  scatterGraph.scene.activeCamera.xRotation;
                        surfaceGraph.scene.activeCamera.yRotation =  scatterGraph.scene.activeCamera.yRotation;
                        scatterGraph.visible = false;
                        surfaceGraph.visible = true;
                        plotChange.text="Scatter";
                    }
                }

            }
            Button {
                id: btnOrtho
                Layout.fillHeight: true
                Layout.fillWidth: true
                text: "Ortho"

                onClicked: {
                    scatterGraph.orthoProjection = !scatterGraph.orthoProjection
                    surfaceGraph.orthoProjection = !surfaceGraph.orthoProjection
                }
            }
            Slider {
                id: zoomSlider
                Layout.fillWidth: true
                from: 100
                to: 0.1
                value: 40.0
                onValueChanged: {
                    surfaceGraph.scene.activeCamera.zoomLevel=value;
                    scatterGraph.scene.activeCamera.zoomLevel=value;
                }
            }


            Button {
                id: btnClose
                Layout.fillHeight: true
                Layout.fillWidth: true
                text: "Close"
                onClicked: {
                    bedmatrix.close();
                }
            }
        }

        Component.onCompleted: {
            zoomSlider.to= surfaceGraph.scene.activeCamera.maxZoomLevel;
            zoomSlider.from =surfaceGraph.scene.activeCamera.minZoomLevel;
            zoomSlider.value=surfaceGraph.scene.activeCamera.zoomLevel;
            addMatrix();
        }
    }
}
