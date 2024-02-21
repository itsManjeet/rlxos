#ifndef SRCLANG_LANGUAGE_HXX
#define SRCLANG_LANGUAGE_HXX

#include <filesystem>
#include <tuple>

#include "../Compiler/Compiler.hxx"
#include "../Interpreter/Interpreter.hxx"
#include "Options.hxx"
#include "../Compiler/SymbolTable/SymbolTable.hxx"
#include "../Value/Value.hxx"

#ifdef _WIN32

#include <windows.h>

#else
typedef void* HMODULE;
#include <dlfcn.h>
#include <gnu/lib-names.h>
#endif

namespace srclang {

    struct Language {
        MemoryManager memoryManager;
        Options options;
        SymbolTable symbolTable;

        SrcLangList globals;
        SrcLangList constants;
        std::vector<HMODULE> libraries;

        Language();

        ~Language();

        void define(std::string const &id, Value value);

        size_t add_constant(Value value);

        Value register_object(Value value);

        Value resolve(std::string const &id);

        void load_library(const std::string &id);

        template<typename T>
        T get_function(const std::string &id) {
            T symbol = nullptr;
            for (auto c: libraries) {
#ifdef _WIN32
                symbol = (T) GetProcAddress(c, id.c_str());
#else
                symbol = (T) dlsym(c, id.c_str());
#endif
                if (symbol != nullptr) break;
            }
            return symbol;
        }

        std::tuple<Value, ByteCode, std::shared_ptr<DebugInfo>>
        compile(std::string const &input, std::string const &filename);

        Value execute(std::string const &input, std::string const &filename);

        Value execute(ByteCode &code, const std::shared_ptr<DebugInfo> &debugInfo);

        Value execute(const std::filesystem::path &filename);

        Value call(Value callee, std::vector<Value> const &args);

        void appendSearchPath(std::string const &path);
    };

}  // namespace srclang

#endif
