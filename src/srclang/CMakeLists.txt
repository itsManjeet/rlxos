cmake_minimum_required(VERSION 3.20)
project(srclang
        VERSION "2.0.0"
        DESCRIPTION "Source Programming Language"
        LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(srclang
        ByteCode/ByteCode.hxx ByteCode/ByteCode.cxx
        ByteCode/DebugInfo.hxx
        Compiler/Compiler.cxx Compiler/Compiler.hxx
        Compiler/SymbolTable/SymbolTable.cxx Compiler/SymbolTable/SymbolTable.hxx
        Interpreter/Interpreter.cxx Interpreter/Interpreter.hxx
        Interpreter/Builtins/Builtin.cxx Interpreter/Builtins/Builtin.hxx
        Interpreter/MemoryManager/MemoryManager.cxx Interpreter/MemoryManager/MemoryManager.hxx
        Language/Language.cxx Language/Language.hxx
        Language/Options.cxx Language/Options.hxx
        Value/Value.cxx Value/Value.hxx
        main.cpp)

find_library(FFI ffi REQUIRED)
find_library(DL dl REQUIRED)
target_link_libraries(srclang PUBLIC
        ${FFI}
        ${DL})

install(TARGETS srclang
        RUNTIME DESTINATION bin)
