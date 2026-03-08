cmake_minimum_required(VERSION 3.21)

project(ulysses_ground_control
    VERSION 0.1.0
    LANGUAGES CXX C
)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# ----------------------------------------------------------------------
# rocket-protocol-lib sources
# ----------------------------------------------------------------------
set(ROCKET_PROTOCOL_SRC
    ${CMAKE_CURRENT_SOURCE_DIR}/rocket-protocol-lib/src/codec.c
    ${CMAKE_CURRENT_SOURCE_DIR}/rocket-protocol-lib/src/cobs/cobs.c
    ${CMAKE_CURRENT_SOURCE_DIR}/rocket-protocol-lib/src/crc/crc16.c
)

# ----------------------------------------------------------------------
# Add nanopb
# ----------------------------------------------------------------------
set(NANOPB_SRC
    ${CMAKE_CURRENT_SOURCE_DIR}/rocket-protocol-lib/nanopb/pb_encode.c
    ${CMAKE_CURRENT_SOURCE_DIR}/rocket-protocol-lib/nanopb/pb_decode.c
    ${CMAKE_CURRENT_SOURCE_DIR}/rocket-protocol-lib/nanopb/pb_common.c
)

# ----------------------------------------------------------------------
# Add Protobuf generated files
# ----------------------------------------------------------------------
set(PROTOBUF_SRC
    ${CMAKE_CURRENT_SOURCE_DIR}/rocket-protocol-lib/generated/tvr/command.pb.c
    ${CMAKE_CURRENT_SOURCE_DIR}/rocket-protocol-lib/generated/tvr/common.pb.c
    ${CMAKE_CURRENT_SOURCE_DIR}/rocket-protocol-lib/generated/tvr/status.pb.c
    ${CMAKE_CURRENT_SOURCE_DIR}/rocket-protocol-lib/generated/tvr/telemetry.pb.c
    ${CMAKE_CURRENT_SOURCE_DIR}/rocket-protocol-lib/generated/tvr/downlink.pb.c
)

# ----------------------------------------------------------------------
# Qt 6 modules
# ----------------------------------------------------------------------
find_package(Qt6 REQUIRED COMPONENTS
    Core
    Gui
    Qml
    Quick
    QuickControls2
    Quick3D
    SerialPort
)

# ----------------------------------------------------------------------
# Paths (relative to project root)
# ----------------------------------------------------------------------
set(HEAD_DIR "HeadFiles")
set(SRC_DIR  "SourceFiles")
set(QML_DIR  "QMLFiles")

include_directories("${CMAKE_CURRENT_SOURCE_DIR}/${HEAD_DIR}")
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/rocket-protocol-lib/include")
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/rocket-protocol-lib/generated/tvr")
include_directories("${CMAKE_CURRENT_SOURCE_DIR}//rocket-protocol-lib/nanopb")
include_directories("${CMAKE_CURRENT_SOURCE_DIR}")

file(GLOB_RECURSE MESH_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "QMLFiles/meshes/*.mesh")
# ----------------------------------------------------------------------
# C++ sources + headers
# ----------------------------------------------------------------------
set(SRC_FILES
    "${SRC_DIR}/main.cpp"
    "${SRC_DIR}/SerialBridge.cpp"
    "${SRC_DIR}/CommandSender.cpp"
    "${SRC_DIR}/AlarmReceiver.cpp"
    "${SRC_DIR}/SensorDataModel.cpp"
    ${PROTOBUF_SRC}
    ${NANOPB_SRC}
    ${ROCKET_PROTOCOL_SRC}
)

set(HDR_FILES
    "${HEAD_DIR}/SerialBridge.h"
    "${HEAD_DIR}/CommandSender.h"
    "${HEAD_DIR}/AlarmReceiver.h"
    "${HEAD_DIR}/SensorDataModel.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/rocket-protocol-lib/generated/tvr/command.pb.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/rocket-protocol-lib/include/rp/codec.h"
)

# ----------------------------------------------------------------------
# Executable target
# ----------------------------------------------------------------------
qt_add_executable(ulysses_ground_control
    MACOSX_BUNDLE
    MANUAL_FINALIZATION
    ${SRC_FILES}
    ${HDR_FILES}
)

# ----------------------------------------------------------------------
# QML module
# ----------------------------------------------------------------------
set_source_files_properties("${QML_DIR}/Items/Theme.qml"
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(ulysses_ground_control
    URI ulysses_ground_control
    VERSION 1.0
    QML_FILES
        "${QML_DIR}/FullDroneAssembly.qml"
        "${QML_DIR}/Header.qml"
        "${QML_DIR}/LayoutGrid.qml"
        "${QML_DIR}/Main.qml"
        "${QML_DIR}/RadioOutputWindow.qml"
        "${QML_DIR}/RadioTestWindow.qml"
        "${QML_DIR}/Shortcuts.qml"
        "${QML_DIR}/Panels/Panel_State_And_Position.qml"
        "${QML_DIR}/Panels/Panel_Control.qml"
        "${QML_DIR}/Panels/Panel_Angles_And_Engine.qml"
        "${QML_DIR}/Panels/Panel_PID_Controller.qml"
        "${QML_DIR}/Panels/Panel_Rocket_Visualization.qml"
        "${QML_DIR}/Panels/Panel_System_Alert.qml"
        "${QML_DIR}/Panels/Panel_System_Health.qml"
        "${QML_DIR}/Items/BaseHeader.qml"
        "${QML_DIR}/Items/BasePanel.qml"
        "${QML_DIR}/Items/CommandCard.qml"
        "${QML_DIR}/Items/DataBox.qml"
        "${QML_DIR}/Items/DataBoxList.qml"
        "${QML_DIR}/Items/Theme.qml"
    RESOURCES
        "${MESH_FILES}"
        "${QML_DIR}/Items/qmldir"
)

# ----------------------------------------------------------------------
# Link Qt libraries
# ----------------------------------------------------------------------
target_link_libraries(ulysses_ground_control
    PRIVATE
        Qt6::Core
        Qt6::Gui
        Qt6::Qml
        Qt6::Quick
        Qt6::QuickControls2
        Qt6::Quick3D
        Qt6::SerialPort
)

qt_import_qml_plugins(ulysses_ground_control)
qt_finalize_executable(ulysses_ground_control)
