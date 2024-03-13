cmake_minimum_required(VERSION 3.20)
project(dev.rlxos.WelcomeTour
        VERSION "0.0.1"
        DESCRIPTION "Welcome Tour"
        LANGUAGES C CXX)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(GLibUtils)
include(GNUInstallDirs)

find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK IMPORTED_TARGET REQUIRED gtkmm-3.0)

set(GENERATED_GRESOURCE_FILE ${PROJECT_BINARY_DIR}/gresource.c)
add_executable(${PROJECT_NAME}
        main.cpp
        Application.cpp
        Application.h
        Window.cpp
        Window.h
        ${GENERATED_GRESOURCE_FILE}
)

compile_resources(${PROJECT_SOURCE_DIR}/gresource.xml
        ${GENERATED_GRESOURCE_FILE}
        Window.ui)

target_link_libraries(${PROJECT_NAME} PRIVATE
        PkgConfig::GTK)

install(TARGETS ${PROJECT_NAME}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})