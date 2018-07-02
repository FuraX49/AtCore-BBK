import QtQuick 2.11
import QtQuick.Scene3D 2.0
import Qt3D.Render 2.0
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11

import "../GCodeViewer" as AP

Item {
    function drawgcode(filename ) {
        root.gcodemesh.source=filename;
    }

    Rectangle {
        id: scene
        x :0
        y : 0
        width : mainpage.width
        height : mainpage.height
        z : 999


        color: "White"

        transform: Rotation {
            id: sceneRotation
            axis.x: 1
            axis.y: 0
            axis.z: 0
            origin.x: scene.width / 2
            origin.y: scene.height / 2
        }

        Scene3D {
            id: scene3d
            multisample: true
            anchors.fill: parent
            anchors.margins: 0
            focus: true
            aspects: ["input", "logic"]
            cameraAspectRatioMode: Scene3D.AutomaticAspectRatio

            AP.SceneRoot {
                id: root
                zoom: zoomSlider.value
            }

        }
        ColumnLayout {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5
            anchors.left: parent.horizontalCenter
            anchors.leftMargin: parent.width * 0.20
            anchors.right: parent.right
            anchors.rightMargin: 5
            spacing: 5


            GridLayout {
                columns :3
                rows : 3

                Button {
                    id: btnUp
                    Layout.column : 1
                    Layout.row : 0
                    text: "\u02c4"
                    Layout.maximumHeight: 40
                    Layout.maximumWidth: 40
                    autoRepeat: true
                    onClicked: {
                        root.camera.translate(Qt.vector3d(0.0,-1.0, 0.0)) ;
                    }
                }
                Button {
                    id: btnLeft
                    Layout.maximumHeight: 40
                    Layout.maximumWidth: 40
                    Layout.column : 0
                    Layout.row : 1
                    text: "\u02c2"
                    autoRepeat: true
                    onClicked: {
                        root.camera.translate(Qt.vector3d(1.0,0.0, 0.0)) ;
                    }
                }

                RoundButton {
                    id: btnCenter
                    text: "O"
                    Layout.column : 1
                    Layout.row : 1
                    Layout.maximumHeight: 40
                    Layout.maximumWidth: 40
                    autoRepeat: false
                    onClicked: {
                        root.camera.setViewCenter(Qt.vector3d(0.0, 0.0, 0.0)) ;
                    }
                }
                Button {
                    id: btnRight
                    Layout.column : 2
                    Layout.row : 1
                    Layout.maximumHeight: 40
                    Layout.maximumWidth: 40
                    autoRepeat: true
                    text: "\u02c3"
                    onClicked: {
                        root.camera.translate(Qt.vector3d(-1.0,0.0, 0.0)) ;
                    }
                }
                Button {
                    id: btnDown
                    Layout.column : 1
                    Layout.row : 2
                    autoRepeat: true
                    text: "\u02c5"
                    Layout.maximumHeight: 40
                    Layout.maximumWidth: 40
                    onClicked: {
                        root.camera.translate(Qt.vector3d(0.0,1.0, 0.0 )) ;
                    }
                }
            }



            Text { text: "Zoom" }
            Slider {
                id: zoomSlider
                Layout.fillWidth: true
                from: 100
                to: 0.1
                value: 40.0
            }

            Text { text: "Roll" }
            Slider {
                id: rotX
                Layout.fillWidth: true
                from: 0
                to: 2 * Math.PI
                value: Math.PI
                onValueChanged: {
                    root.camera.rollAboutViewCenter(value);
                }
            }

            Text { text: "Tilt" }
            Slider {
                id: rotY
                Layout.fillWidth: true
                from: 0
                to: 2 * Math.PI
                value: Math.PI
                onValueChanged: {
                    root.camera.tiltAboutViewCenter(value);
                }
            }

            Text { text: "Pan" }
            Slider {
                id: rotZ
                Layout.fillWidth: true
                from: 0
                to: 2 * Math.PI
                value: Math.PI
                onValueChanged: {
                    root.camera.panAboutViewCenter(value);
                }
            }

            Button {
                id: btnClose
                width: 80
                height: 30
                text: "Close"
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                onClicked: {
                    mainpage.destroy3DViewer();
                }
            }

        }
    }
}

