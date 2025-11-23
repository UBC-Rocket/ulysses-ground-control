import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick3D
import QtQuick3D.Helpers
import "Items"

BasePanel {
    id: panel_Rocket_Visualization

    // Panel header title
    BaseHeader {
        id: header
        headerText: "Rocket Visualization"
    }

    // Main container for the 3D visualization
    Item {
        id: visualization

        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: 10
            rightMargin: 10
            bottomMargin: 10
        }

        // Live angles received from SensorDataModel (IMU values)
        property real x_kal:   sensorData.imuX
        property real y_kal:   sensorData.imuY
        property real z_roll:  sensorData.imuZ

        // Visualization parameters
        property real length:    200    // helper line length
        property real thickness: 0.4    // helper line thickness

        // 3D view that renders the rocket and axis helpers
        View3D {
            anchors.fill: parent

            // Camera used to look at the rocket
            PerspectiveCamera {
                id: cam
                position: Qt.vector3d(4500, 2000, 4500)
                lookAtNode: rocket_frame
            }

            // Simple scene environment (solid background color)
            environment: SceneEnvironment {
                backgroundMode: SceneEnvironment.Color
                clearColor: "#1F2937"
            }

            // Single directional light for basic shading
            DirectionalLight { }

            // Root node for the rocket model and its orientation
            Node {
                id: rocket_frame

                // Apply IMU-based rotation (Qt uses Y-up; axes remapped here)
                eulerRotation: Qt.vector3d(visualization.x_kal,
                                           visualization.z_roll,
                                           visualization.y_kal)
                pivot: Qt.vector3d(0, 0, 0)

                // Rocket geometry parameters
                property real d:       10       // body diameter
                property real h_body:  30       // body height
                property real h_nose:  h_body/3 // nose height

                // Main rocket body (cylinder)
                Model {
                    source: "#Cylinder"
                    scale: Qt.vector3d(rocket_frame.d,
                                       rocket_frame.h_body,
                                       rocket_frame.d)
                    materials: DefaultMaterial {
                        diffuseColor: "#d9d9d9"
                    }
                }

                // Nose cone on top of the body
                Model {
                    source: "#Cone"
                    position: Qt.vector3d(0, 1500, 0)
                    scale: Qt.vector3d(rocket_frame.d,
                                       rocket_frame.h_nose,
                                       rocket_frame.d)
                    materials: DefaultMaterial {
                        diffuseColor: "#d9d9d9"
                    }
                }

                // Helper line along one axis (e.g., pitch)
                Model {
                    source: "#Cylinder"
                    scale: Qt.vector3d(visualization.thickness,
                                       visualization.length,
                                       visualization.thickness)
                    materials: DefaultMaterial {
                        diffuseColor: "green"
                    }
                }

                // Helper line rotated 90° (e.g., roll)
                Model {
                    source: "#Cylinder"
                    eulerRotation: Qt.vector3d(0, 0, 90)
                    scale: Qt.vector3d(visualization.thickness,
                                       visualization.length,
                                       visualization.thickness)
                    materials: DefaultMaterial {
                        diffuseColor: "red"
                    }
                }

                // Offset helper line for extra reference (e.g., yaw)
                Model {
                    source: "#Cylinder"
                    position: Qt.vector3d(15000, 0, 0)
                    eulerRotation: Qt.vector3d(90, 0, 0)
                    scale: Qt.vector3d(visualization.thickness,
                                       visualization.length,
                                       visualization.thickness)
                    materials: DefaultMaterial {
                        diffuseColor: "blue"
                    }
                }
            }

            // World axes and grids for orientation reference
            AxisHelper {
                enableAxisLines: true
                enableXYGrid: true
                enableXZGrid: false
                enableYZGrid: true
                gridOpacity: 0.2
                scale: Qt.vector3d(10, 10, 10)
            }

            // Keyboard controller to move the camera (WASD)
            WasdController {
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
    }
}

