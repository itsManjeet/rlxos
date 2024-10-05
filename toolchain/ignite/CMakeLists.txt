add_executable(ignite
        main.cpp
        Ignite.cpp Ignite.h
        Container.cpp Container.h
        Configuration.cpp Configuration.h
        Recipe.cpp Recipe.h
        Executor.cpp Executor.h)

target_link_libraries(ignite PRIVATE
        yaml-cpp)