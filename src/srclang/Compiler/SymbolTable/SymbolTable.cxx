#include "SymbolTable.hxx"

using namespace srclang;

Symbol SymbolTable::define(const std::string &name) {
    store[name] =
        Symbol{name, (parent == nullptr ? Symbol::GLOBAL : Symbol::LOCAL),
               definitions++};
    return store[name];
}

Symbol SymbolTable::define(const std::string &name, int index) {
    store[name] = Symbol{name, Symbol::BUILTIN, index};
    return store[name];
}

Symbol SymbolTable::define(const Symbol &other) {
    free.push_back(other);
    auto sym = Symbol{other.name, Symbol::FREE, (int)free.size() - 1};
    store[other.name] = sym;
    return sym;
}

std::optional<Symbol> SymbolTable::resolve(const std::string &name) {
    auto iter = store.find(name);
    if (iter != store.end()) {
        return iter->second;
    }
    if (parent != nullptr) {
        auto sym = parent->resolve(name);
        if (sym == std::nullopt) {
            return sym;
        }

        if (sym->scope == Symbol::Scope::GLOBAL ||
            sym->scope == Symbol::Scope::BUILTIN ||
            sym->scope == Symbol::Scope::TYPE) {
            return sym;
        }
        return define(*sym);
    }
    return std::nullopt;
}

SymbolTable::SymbolTable(SymbolTable *parent) : parent{parent} {
}
