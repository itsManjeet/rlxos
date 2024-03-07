#ifndef SRCLANG_BYTECODE_HXX
#define SRCLANG_BYTECODE_HXX

#include <iomanip>
#include <memory>

#include "Instructions.hxx"
#include "../Value/Value.hxx"

namespace srclang {

    struct ByteCode {
        std::unique_ptr<Instructions> instructions;
        std::vector<Value> constants;
        using Iterator = typename std::vector<Value>::iterator;

        static int debug(Instructions const &instructions,
                         std::vector<Value> const &constants, int offset,
                         std::ostream &os);

        friend std::ostream &operator<<(std::ostream &os,
                                        const ByteCode &bytecode) {
            os << "== CODE ==" << std::endl;
            for (int offset = 0; offset < bytecode.instructions->size();) {
                offset = ByteCode::debug(
                    *bytecode.instructions, bytecode.constants, offset, os);
                os << std::endl;
            }
            os << "\n== CONSTANTS ==" << std::endl;
            for (auto i = 0; i < bytecode.constants.size(); i++) {
                os << i << " " << SRCLANG_VALUE_DEBUG(bytecode.constants[i])
                   << std::endl;
            }
            return os;
        }
    };

}  // srclang

#endif  // SRCLANG_BYTECODE_HXX
