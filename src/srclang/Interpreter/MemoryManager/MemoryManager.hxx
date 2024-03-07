#ifndef SRCLANG_MEMORYMANAGER_HXX
#define SRCLANG_MEMORYMANAGER_HXX

#include "../../Value/Value.hxx"

namespace srclang {

    struct HeapObject {
        ValueType type{};
        void *pointer{nullptr};
        bool is_ref{false};
        size_t size{0};

        bool marked{false};

        void (*cleanup)(void *) = free;
    };

#define SRCLANG_CLEANUP_FN(fn) ((void (*)(void *))fn)

    static inline Value srclang_value_set_ref(Value value) {
        if (!SRCLANG_VALUE_IS_OBJECT(value)) return value;
        SRCLANG_VALUE_AS_OBJECT(value)->is_ref = true;
        return value;
    }

    static inline Value srclang_value_set_size(Value value, size_t size) {
        if (!SRCLANG_VALUE_IS_OBJECT(value)) return value;
        SRCLANG_VALUE_AS_OBJECT(value)->size = size;
        return value;
    }

    static inline size_t srclang_value_get_size(Value value) {
        if (!SRCLANG_VALUE_IS_OBJECT(value)) return 0;
        return SRCLANG_VALUE_AS_OBJECT(value)->size;
    }

    static inline Value srclang_value_set_cleanup(Value value, void (*c)(void *)) {
        if (!SRCLANG_VALUE_IS_OBJECT(value)) return value;
        SRCLANG_VALUE_AS_OBJECT(value)->cleanup = c;
        return value;
    }

    class MemoryManager {
       private:
       public:
        using Heap = std::vector<Value>;

        Heap heap;

        MemoryManager() = default;

        ~MemoryManager();

        void mark(Value val);

        void mark(Heap::iterator start, Heap::iterator end);

        void sweep();
    };

}  // srclang

#endif  // SRCLANG_MEMORYMANAGER_HXX
