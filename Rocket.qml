import QtQuick
import QtQuick3D

Node {
    id: node

    // Resources
    PrincipledMaterial {
        id: defaultMaterial_material
        objectName: "DefaultMaterial"
    }

    // Nodes:
    Node {
        id: _STL_BINARY_
        objectName: "<STL_BINARY>"
        Model {
            id: model
            source: "meshes/node3.mesh"
            materials: [
                defaultMaterial_material
            ]
        }
    }

    // Animations:
}
