cmake_minimum_required(VERSION 3.20)
project(rlxos
        VERSION "2.0"
        DESCRIPTION "Immutable OpenSource OS"
        LANGUAGES C CXX ASM)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

list(PREPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)

include_directories(src)

add_subdirectory(src)
