import QtQuick
import QtQuick3D

Node {
    id: node
    property bool _centered: false
    // expose inner model if you want to access it from outside
    property alias mesh: model

    PrincipledMaterial { id: defaultMaterial_material }

    Node {
        id: rocket_stl
        Model {
            id: model
            source: "meshes/node3.mesh"
            materials: [ defaultMaterial_material ]

            // recenter once when bounds become valid
            onBoundsChanged: {
                if (_centered) return;
                const b = bounds;
                const cx = (b.maximum.x - b.minimum.x)/2
                const cy = (b.maximum.x - b.minimum.y)/2
                const cz = (b.maximum.z - b.minimum.z)/2
                position = Qt.vector3d(-cx, cy, -cz);  // move mesh so center is (0,0,0)
                pivot    = Qt.vector3d(cx, cy, cz);     // rotate about its own center
                _centered = true;
                console.log("rocket recentered:", cx, cy, cz);
            }
        }
    }
}
