cmake_minimum_required(VERSION 3.16)

project(radio_test_2 VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Qml SerialPort)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appradio_test_2
)

qt_add_qml_module(appradio_test_2
    URI radio_test_2
    VERSION 1.0
    QML_FILES
    Main.qml
    SOURCES main.cpp
    SOURCES SerialBridge.h
    SOURCES SerialBridge.h
    SOURCES SerialBridge.cpp

)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appradio_test_2 PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appradio_test_2
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appradio_test_2
    PRIVATE Qt6::Quick
            Qt6::SerialPort
            Qt6::Qml
)

include(GNUInstallDirs)
install(TARGETS appradio_test_2
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
