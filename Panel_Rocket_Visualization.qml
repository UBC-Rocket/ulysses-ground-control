import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick3D
import QtQuick3D.Helpers


Rectangle {
    //Parameters

    //Initializing the Panel
    id: panel_Rocket_Visualization
    color: "#1F2937"
    border.color: "#2d3748"
    border.width: 4
    radius: 8
    height: (parent.parent.height - 20)/2 - 10
    width: (parent.parent.width - 20)/4 - 5


    Rectangle {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 15
        anchors.leftMargin: 15
        height: 50
        Text {
            //Initializing Header for Rocket Visualization
            id: header_Rocket_Visualization
            color: "#93C5FD"
            text: "Rocket Visualization"
            font.pixelSize: 20
            font.bold: true
        }
    }

    Item {
        id: visualization
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 10
        anchors.leftMargin: 10
        anchors.bottomMargin: 10

        //Variables & Constants declared
           property real x_kal: 0
           property real y_kal: 0
           property real length: 200        // shaft length
           property real thickness: 0.2       // shaft thickness

           //FAKE DATA


           Timer {
               interval: 16
               repeat: true
               running: true
               triggeredOnStart: true
               property real t: 0
               onTriggered: {
                   t += interval/1000
                   visualization.x_kal = 25 * Math.sin(2*Math.PI*0.27 * t)          // generating random fake X angle
                   visualization.y_kal = 35 * Math.sin(2*Math.PI*0.19 * t + 1.1)    // fake Y angle
               }
           }




           //3D render of rocket's angle
           View3D{
               anchors.fill: parent

               PerspectiveCamera{
                   id: cam
                   position: Qt.vector3d(4500,2000,4500)
                   lookAtNode: rocket_frame
               }

               environment: SceneEnvironment{
                   backgroundMode: SceneEnvironment.Color
                   clearColor: "#1F2937"
               }

               DirectionalLight{}



               //The actual rocket framh
               Node{
                   id: rocket_frame

                   //Qt has y-axis pointing up by default. So the y-axis rotation is actually the "z-axis"
                   eulerRotation: Qt.vector3d(visualization.x_kal, 0, visualization.y_kal)
                   pivot: Qt.vector3d(0,0,0)

                   property real d: 10          // diameter
                   property real h_body: 30    // cylinder height
                   property real h_nose: h_body/3

                   Model{
                           source: "#Cylinder"
                           scale: Qt.vector3d(rocket_frame.d, rocket_frame.h_body, rocket_frame.d)
                           materials: DefaultMaterial { diffuseColor: "#d9d9d9" }
                   }

                   Model {
                       source: "#Cone"
                       position: Qt.vector3d(0,1500,0)
                       scale: Qt.vector3d(rocket_frame.d, rocket_frame.h_nose, rocket_frame.d)
                       materials: DefaultMaterial { diffuseColor: "#d9d9d9" }
                   }

                   //Helper lines to visualize tilt
                   Model{
                       source: "#Cylinder"
                       scale: Qt.vector3d(visualization.thickness, visualization.length, visualization.thickness)
                       materials: DefaultMaterial{
                           diffuseColor: "green"
                       }
                   }

                   Model{
                       source: "#Cylinder"
                       eulerRotation: Qt.vector3d(0,0,90)
                       scale: Qt.vector3d(visualization.thickness, visualization.length, visualization.thickness)
                       materials: DefaultMaterial{
                           diffuseColor: "red"
                       }
                   }

                   Model{
                       source: "#Cylinder"
                       eulerRotation: Qt.vector3d(90,0,0)
                       scale: Qt.vector3d(visualization.thickness, visualization.length, visualization.thickness)
                       materials: DefaultMaterial{
                           diffuseColor: "blue"
                       }
                   }

               }

               AxisHelper{
                   enableAxisLines: true
                   enableXYGrid: true
                   enableXZGrid: false
                   enableYZGrid: true
                   gridOpacity: 0.2
                   scale: Qt.vector3d(10,10,10)
               }

               //Press A and D to switch move view of camera
               WasdController{
                   controlledObject: cam
                   leftSpeed: 20
                   rightSpeed: 20
                   forwardSpeed: 10
                   backSpeed: 10
                   upSpeed: 0
                   downSpeed: 0
                   mouseEnabled: false
               }
           }

           //HUD of angle
           Rectangle {
               id: hud
               anchors.top: parent.top
               anchors.right: parent.right
               anchors.margins: 10
               z: 100
               radius: 8
               color: "#00000080"
               border.color: "#ffffff20"; border.width: 1

               // size to content
               width: 60
               height: 50

               Column {
                   id: col
                   anchors.centerIn: parent
                   spacing: 4
                   Text { text: "X: " + visualization.x_kal.toFixed(1) + "°"; color: "blue"; font.pixelSize: 14 }
                   Text { text: "Y: " + visualization.y_kal.toFixed(1) + "°"; color: "red"; font.pixelSize: 14 }
               }
           }
    }
}
