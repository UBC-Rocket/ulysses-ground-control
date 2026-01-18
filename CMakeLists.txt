cmake_minimum_required(VERSION 3.21)

project(ulysses_ground_control
    VERSION 0.1.0
    LANGUAGES CXX
)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

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
set(HEAD_DIR "Head Files")
set(SRC_DIR  "Source Files")
set(QML_DIR  "QML Files")

include_directories("${CMAKE_CURRENT_SOURCE_DIR}/${HEAD_DIR}")

# ----------------------------------------------------------------------
# C++ sources + headers
# ----------------------------------------------------------------------
set(SRC_FILES
    "${SRC_DIR}/main.cpp"
    "${SRC_DIR}/SerialBridge.cpp"
    "${SRC_DIR}/CommandSender.cpp"
    "${SRC_DIR}/AlarmReceiver.cpp"
    "${SRC_DIR}/SensorDataModel.cpp"
)

set(HDR_FILES
    "${HEAD_DIR}/SerialBridge.h"
    "${HEAD_DIR}/CommandSender.h"
    "${HEAD_DIR}/AlarmReceiver.h"
    "${HEAD_DIR}/SensorDataModel.h"
)

# ----------------------------------------------------------------------
# Executable target
# ----------------------------------------------------------------------
qt_add_executable(ulysses_ground_control
    MACOSX_BUNDLE
    MANUAL_FINALIZATION
    ${SRC_FILES}
    ${HDR_FILES}       # just so Qt Creator shows a Header Files group
)

# ----------------------------------------------------------------------
# QML module  (ALL paths here are RELATIVE, no absolute ${CMAKE_CURRENT_SOURCE_DIR})
# ----------------------------------------------------------------------
qt_add_qml_module(ulysses_ground_control
    URI ulysses_ground_control         # import ulysses_ground_control
    VERSION 1.0
    QML_FILES
        "${QML_DIR}/Main.qml"
        "${QML_DIR}/Header.qml"
        "${QML_DIR}/LayoutGrid.qml"
        "${QML_DIR}/Panel_Baro_And_Telemetry_Data.qml"
        "${QML_DIR}/Panel_Control.qml"
        "${QML_DIR}/Panel_PID_Slider.qml"
        "${QML_DIR}/Panel_Kalman_and_Engine.qml"
        "${QML_DIR}/Panel_Rocket_Visualization.qml"
        "${QML_DIR}/Panel_System_Alert.qml"
        "${QML_DIR}/Panel_Test.qml"
        "${QML_DIR}/RadioTestWindow.qml"
        "${QML_DIR}/Shortcuts.qml"
        "${QML_DIR}/SettingsPage.qml"
        "${QML_DIR}/Items/BaseHeader.qml"
        "${QML_DIR}/Items/BasePanel.qml"
        "${QML_DIR}/Items/Data.qml"
        "${QML_DIR}/Items/DataBox.qml"
        "${QML_DIR}/Items/DataBoxList.qml"
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
