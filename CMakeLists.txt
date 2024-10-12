cmake_minimum_required(VERSION 3.20)
project(rlxos
        VERSION "2.0"
        DESCRIPTION "Immutable OpenSource OS"
        LANGUAGES C CXX ASM)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

option(TOOLCHAIN "Build toolchain" ON)

add_subdirectory(system)

if (TOOLCHAIN)
        add_subdirectory(toolchain)
endif()