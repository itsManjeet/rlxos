#include "Value.hxx"

#include "Function.hxx"
#include "../Interpreter/MemoryManager/MemoryManager.hxx"
#include <sstream>

using namespace srclang;

void srclang::SRCLANG_VALUE_FREE(Value value) {
    if (!SRCLANG_VALUE_IS_OBJECT(value)) {
        return;
    }
    auto type = SRCLANG_VALUE_GET_TYPE(value);
    auto object = SRCLANG_VALUE_AS_OBJECT(value);
    if (!object->is_ref) {
        switch (type) {
            case ValueType::String:
            case ValueType::Error:
                free((char *) object->pointer);
                break;

            case ValueType::List:
                delete reinterpret_cast<SrcLangList *>(object->pointer);
                break;

            case ValueType::Map:
                delete reinterpret_cast<SrcLangMap *>(object->pointer);
                break;

            case ValueType::Function:
                delete reinterpret_cast<Function *>(object->pointer);
                break;

            case ValueType::Closure:
                delete reinterpret_cast<Closure *>(object->pointer);
                break;

            case ValueType::Bounded:
                delete reinterpret_cast<BoundedValue *>(object->pointer);
                break;

            case ValueType::Pointer:
                object->cleanup(object->pointer);
                break;

            case ValueType::Native:
                delete reinterpret_cast<NativeFunction *>(object->pointer);
                break;

            case ValueType::Builtin:
                break;

            default:
                throw std::runtime_error("can't clean value of type '" + SRCLANG_VALUE_TYPE_ID[int(type)] + "'");
        }
    }

    delete object;
}


ValueType srclang::SRCLANG_VALUE_GET_TYPE(Value val) {
    if (SRCLANG_VALUE_IS_NULL(val)) return ValueType::Null;
    if (SRCLANG_VALUE_IS_BOOL(val)) return ValueType::Boolean;
    if (SRCLANG_VALUE_IS_NUMBER(val)) return ValueType::Number;
    if (SRCLANG_VALUE_IS_TYPE(val)) return ValueType::Type;

    if (SRCLANG_VALUE_IS_OBJECT(val))
        return (SRCLANG_VALUE_AS_OBJECT(val)->type);
    throw std::runtime_error("invalid value '" + std::to_string((uint64_t) val) + "'");
}

std::string srclang::SRCLANG_VALUE_GET_STRING(Value val) {
    auto type = SRCLANG_VALUE_GET_TYPE(val);
    switch (type) {
        case ValueType::Null:
            return "null";
        case ValueType::Boolean:
            return SRCLANG_VALUE_AS_BOOL(val) ? "true" : "false";
        case ValueType::Number: {
            auto value = std::to_string(SRCLANG_VALUE_AS_NUMBER(val));
            auto idx = value.find_last_not_of('0');
            value = value.substr(0, idx + 1);
            if (value.back() == '.') value.pop_back();
            return value;
        }

        case ValueType::Type:
            return "<type(" +
                   SRCLANG_VALUE_TYPE_ID[int(SRCLANG_VALUE_AS_TYPE(val))] +
                   ")>";
        default:
            if (SRCLANG_VALUE_IS_OBJECT(val)) {
                auto object = SRCLANG_VALUE_AS_OBJECT(val);
                switch (type) {
                    case ValueType::String:
                    case ValueType::Error:
                        return (char *) object->pointer;
                    case ValueType::List: {
                        std::stringstream ss;
                        ss << "[";
                        std::string sep;
                        for (auto const &i: *(reinterpret_cast<SrcLangList *>(object->pointer))) {
                            ss << sep << SRCLANG_VALUE_GET_STRING(i);
                            sep = ", ";
                        }
                        ss << "]";
                        return ss.str();
                    }
                        break;

                    case ValueType::Map: {
                        std::stringstream ss;
                        ss << "{";
                        std::string sep;
                        for (auto const &i: *(reinterpret_cast<SrcLangMap *>(object->pointer))) {
                            ss << sep << i.first << ":" << SRCLANG_VALUE_GET_STRING(i.second);
                            sep = ", ";
                        }
                        ss << "}";
                        return ss.str();
                    }
                        break;

                    case ValueType::Function: {
                        return "<function()>";
                    }
                        break;

                    case ValueType::Pointer: {
                        std::stringstream ss;
                        ss << "0x" << std::hex << object->pointer;
                        return ss.str();
                    }

                    default:
                        return "<object(" + SRCLANG_VALUE_TYPE_ID[int(type)] + ")>";
                }
            }
    }

    return "<value(" + SRCLANG_VALUE_TYPE_ID[int(type)] + ")>";
}
