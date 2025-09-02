add_executable(ignite
        main.cxx)

target_sources(ignite PRIVATE
    FILE_SET CXX_MODULES
    FILES Configuration.ixx
    Container.ixx
    Executor.ixx
    Recipe.ixx Ignite.ixx)

target_link_libraries(ignite PRIVATE
        yaml-cpp)
