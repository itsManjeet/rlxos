cmake_minimum_required(VERSION 3.20)
project(sysroot
        VERSION "2.0.0"
        DESCRIPTION "System root manager"
        LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(OSTree REQUIRED)

add_executable(sysroot
        Deployment.cpp Deployment.h
        Error.h
        Sysroot.cpp Sysroot.h
        main.cpp)

target_link_libraries(sysroot PUBLIC
        OSTree)

install(TARGETS sysroot
        RUNTIME DESTINATION bin)