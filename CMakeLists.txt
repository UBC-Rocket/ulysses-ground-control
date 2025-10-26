cmake_minimum_required(VERSION 3.16)

project(ulysses_ground_control VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Qml SerialPort )

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appulysses_ground_control
    main.cpp
)

qt_add_qml_module(appulysses_ground_control
    URI ulysses_ground_control
    VERSION 1.0
    QML_FILES
        Main.qml
        Header.qml
        Shortcuts.qml
        LayoutGrid.qml

        Panel_Test.qml
        Panel_IMU_And_Kalman_Data.qml
        Panel_Rocket_Visualization.qml
        Panel_Engine_Control.qml
        Panel_Baro_And_Telemetry_Data.qml
        Panel_System_Alert.qml

        Items/BaseHeader.qml
        Items/BasePanel.qml
        Items/Data.qml
        Items/DataBox.qml
        Items/DataBoxList.qml

        RadioTestWindow.qml

        SOURCES
            SerialBridge.h
            SerialBridge.cpp


)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appulysses_ground_control PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appulysses_ground_control
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appulysses_ground_control
    PRIVATE Qt6::Quick
            Qt6::SerialPort
)

include(GNUInstallDirs)
install(TARGETS appulysses_ground_control
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
