import QtQuick 2.11
import Qt3D.Core 2.0
import Qt3D.Render 2.0
import Qt3D.Input 2.0
import Qt3D.Logic 2.0
import Qt3D.Extras 2.0

import GCodeMesh 1.0
import "../GCodeViewer" as AP

Entity {
    id: sceneRoot
    property alias camera : camera
    property alias gcodemesh : gcodemesh
    property real zoom
    property real  bedwidh: 280.0
    property real  bedheight: 180.0

    Camera {
        id: camera
        projectionType: CameraLens.PerspectiveProjection
        fieldOfView: sceneRoot.zoom
        nearPlane: 0.1
        farPlane: 1000.0
        position: Qt.vector3d(0.0, -180.0, 30.0)
        upVector: Qt.vector3d(0.0, 1.0, 0.0)
        viewCenter: Qt.vector3d(0.0, 0.0, 5.0)
    }

   //
   // OrbitCameraController {
   //     id : orbcamera
   //     camera: camera
   //     linearSpeed: 50
   //     lookSpeed: 500
  //  }

    components: [
        RenderSettings {
            activeFrameGraph: ForwardRenderer {
                id: renderer
                clearColor: "#ffffff"
                camera: camera
            }
            renderPolicy:  RenderSettings.OnDemand
        }

//      ,  InputSettings { }
    ]



    //******************** GCODE ******************************************

    Entity {
        id: gcodeentity

        components: [gcodemesh, gcodetransform, gcodematerial]

        SimpleMaterial {
            id: gcodematerial
            maincolor: "#111133"
        }

        Transform {
            id: gcodetransform
            rotationX: 0

        }

        GCodeMesh {
            id: gcodemesh

        }
    }


}

