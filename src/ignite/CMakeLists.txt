cmake_minimum_required(VERSION 3.20)
project(ignite
        VERSION "2.0.0"
        DESCRIPTION "Ignite build root"
        LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(ignite
        ArchiveManager.cpp ArchiveManager.h
        Builder.cpp Builder.h
        Container.cpp Container.h
        Executor.cpp Executor.h
        Ignite.cpp Ignite.h
        MetaInfo.cpp MetaInfo.h
        Resolver.h
        main.cpp)

find_package(yaml-cpp REQUIRED)
find_library(CURL curl REQUIRED)

target_link_libraries(ignite PUBLIC
        yaml-cpp
        ${CURL})