#ifndef SRCLANG_INSTRUCTIONS_HXX
#define SRCLANG_INSTRUCTIONS_HXX

#include <cstdint>
#include <string>
#include <vector>

#include "DebugInfo.hxx"

namespace srclang {
    using Byte = uint32_t;

#define SRCLANG_OPCODE_LIST \
    X(CONST_, 1)             \
    X(CONST_INT, 1)         \
    X(CONST_TRUE, 0)        \
    X(CONST_FALSE, 0)       \
    X(CONST_NULL, 0)        \
    X(LOAD, 2)              \
    X(STORE, 2)             \
    X(ADD, 0)               \
    X(SUB, 0)               \
    X(MUL, 0)               \
    X(DIV, 0)               \
    X(NEG, 0)               \
    X(NOT, 0)               \
    X(COMMAND, 0)           \
    X(EQ, 0)                \
    X(NE, 0)                \
    X(LT, 0)                \
    X(LE, 0)                \
    X(GT, 0)                \
    X(GE, 0)                \
    X(AND, 0)               \
    X(OR, 0)                \
    X(LAND, 0)              \
    X(LOR, 0)               \
    X(LSHIFT, 0)            \
    X(RSHIFT, 0)            \
    X(MOD, 0)               \
    X(BREAK, 1)             \
    X(CONTINUE, 1)          \
    X(CLOSURE, 2)           \
    X(CALL, 1)              \
    X(PACK, 0)              \
    X(MAP, 0)               \
    X(INDEX, 2)             \
    X(SET, 0)               \
    X(SET_SELF, 1)          \
    X(POP, 0)               \
    X(RET, 0)               \
    X(JNZ, 1)               \
    X(JMP, 1)               \
    X(CHK, 1)               \
    X(DEFER, 0)             \
    X(SIZE, 0)              \
    X(HLT, 0)

    enum class OpCode : uint8_t {
#define X(id, size) id,
        SRCLANG_OPCODE_LIST
#undef X
    };

    static const std::vector<std::string> SRCLANG_OPCODE_ID = {
#define X(id, size) #id,
        SRCLANG_OPCODE_LIST
#undef X
    };

    static const std::vector<int> SRCLANG_OPCODE_SIZE = {
#define X(id, size) size,
        SRCLANG_OPCODE_LIST
#undef X
    };

    class Instructions : public std::vector<Byte> {
       public:
        OpCode last_instruction{};

        Instructions() = default;

        size_t emit(DebugInfo *debug_info, int line) { return 0; }

        template <typename T, typename... Types>
        size_t emit(DebugInfo *debug_info, int line, T byte, Types... operand) {
            size_t pos = this->size();
            this->push_back(static_cast<Byte>(byte));
            debug_info->lines.push_back(line);
            emit(debug_info, line, operand...);
            last_instruction = OpCode(byte);
            return pos;
        }
    };
}

#endif  // SRCLANG_INSTRUCTIONS_HXX
