#include "ByteCode.hxx"

#include "../Compiler/SymbolTable/SymbolTable.hxx"

using namespace srclang;

int ByteCode::debug(Instructions const &instructions,
                    std::vector <Value> const &constants, int offset,
                    std::ostream &os) {
    os << std::setfill('0') << std::setw(4) << offset << " ";
    auto op = static_cast<OpCode>(instructions[offset]);
    os << SRCLANG_OPCODE_ID[static_cast<int>(op)];
    offset += 1;
    switch (op) {
        case OpCode::CONST_: {
            auto pos = instructions[offset++];
            if (!constants.empty()) {
                os << " " << pos << " '"
                   << SRCLANG_VALUE_DEBUG(constants[pos]) << "'";
            }

        }
            break;
        case OpCode::INDEX:
        case OpCode::PACK:
        case OpCode::MAP:
        case OpCode::SET_SELF: {
            os << " " << (int) instructions[offset++];
        }
            break;
        case OpCode::CONTINUE:
        case OpCode::BREAK:
        case OpCode::JNZ:
        case OpCode::JMP: {
            auto pos = instructions[offset++];
            os << " '" << pos << "'";
        }
            break;
        case OpCode::LOAD:
        case OpCode::STORE: {
            auto scope = instructions[offset++];
            auto pos = instructions[offset++];
            os << " " << pos << " '" << SRCLANG_SYMBOL_ID[scope] << "'";
        }
            break;
        case OpCode::CLOSURE: {
            auto constantIndex = instructions[offset++];
            auto nfree = instructions[offset++];
            os << constants[constantIndex] << " " << nfree;
        }
            break;

        case OpCode::CONST_INT:
        case OpCode::CALL: {
            auto count = instructions[offset++];
            os << " '" << count << "'";
        }
            break;
        default:
            offset += SRCLANG_OPCODE_SIZE[int(op)];
            break;
    }

    return offset;
}
