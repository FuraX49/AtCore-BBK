import QtQuick 2.11
import QtQml 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11
import QtDataVisualization 1.2

import "."
import "ParseMsg.js" as PM

Rectangle {
    id: viewMatrix

    width: 800
    height: 480
    color: surfaceGraph.theme.windowColor

    property real  bedwidth : 280.0
    property real  beddepht : 180.0
    property real  minprob  : 0.0
    property real  maxprob  : 0.0



    function addMatrix(probematrix){
        matrixData.clear();
        minprob  = +100.0;
        maxprob  = -100.0;
        var Pb = PM.ProbePoint;

        for (var i = 0; i < probematrix.length; i++) {
            Pb = probematrix[i];
            matrixData.append({"mx": probematrix[i].X, "my": probematrix[i].Y, "mz" : probematrix[i].Z});
            if(probematrix[i].Z> maxprob) maxprob =probematrix[i].Z;
            if(probematrix[i].Z< minprob) minprob =probematrix[i].Z;
        }
        var diff = Math.min(Math.abs(maxprob - minprob),0.5);
        var  incgradient = Math.min(0.5-diff ,0.4999);
        console.log("min " +  minprob  + " Max  " +  maxprob + " INC " +incgradient);
        mingradient.position=0.5-incgradient;
        maxgradient.position=0.5+incgradient;
        yAxis.min =  minprob  ;
        yAxis.max = maxprob  ;

    }

    ListModel {
        id: matrixData
        ListElement{  mx : 20; my: 20; mz: -0.0; }
        ListElement{  mx: 160; my: 20; mz: -0.0; }
        ListElement{  mx: 260; my: 20; mz: -0.0; }

        ListElement{  mx : 20; my: 90; mz: -0.0; }
        ListElement{  mx: 160; my: 90; mz: -0.0; }
        ListElement{  mx: 260; my: 90; mz: -0.1; }

        ListElement{  mx : 20; my:150; mz: -0.0; }
        ListElement{  mx: 160; my:150; mz: -0.0; }
        ListElement{  mx: 260; my:150; mz: -0.0; }
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
            //            segmentCount: 10
            labelFormat: "%i mm"
            title: "X"
            min : 0
            max : bedwidth
            segmentCount: 6
            titleVisible: true
            titleFixed: false
        }


        ValueAxis3D {
            id: zAxis
            labelFormat: "%i mm"
            title: "Y"
            min : 0
            max : beddepht
            segmentCount: 6
            titleVisible: true
            titleFixed: false
        }

        ValueAxis3D {
            id: yAxis
            labelFormat: "%.3f"
            title: "Offset"
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

            //scene.activeCamera.cameraPreset: Camera3D.CameraPresetIsometricLeftHigh

            //            theme: customTheme
            theme: Theme3D {
                type: Theme3D.ThemeRetro  // ThemeIsabelle //ThemeEbony //ThemeRetro // ThemeStoneMoss // ThemeDigia
                font.pointSize: 14
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
            //scene.activeCamera.cameraPreset: Camera3D.CameraPresetIsometricLeftHigh

            theme: Theme3D {
                type: Theme3D.ThemeRetro
                font.pointSize: 14
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
                mainpage.pagerloadBedMatrix.hide();
            }
        }
    }

    Component.onCompleted: {
        zoomSlider.to= surfaceGraph.scene.activeCamera.maxZoomLevel;
        zoomSlider.from =surfaceGraph.scene.activeCamera.minZoomLevel;
        zoomSlider.value=surfaceGraph.scene.activeCamera.zoomLevel;
    }
}
