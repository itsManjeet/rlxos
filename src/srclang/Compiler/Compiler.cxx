#include "Compiler.hxx"

#include <algorithm>
#include <filesystem>
#include <fstream>
#include <ranges>

#include "../Language/Language.hxx"

using namespace srclang;

template<class V>
std::type_info const &variant_typeid(V const &v) {
    return visit([](auto &&x) -> decltype(auto) { return typeid(x); }, v);
}

ByteCode Compiler::code() {
    return ByteCode{std::move(instructions.back()), language->constants};
}

Instructions *Compiler::inst() { return instructions.back().get(); }

void Compiler::push_scope() {
    symbol_table = new SymbolTable(symbol_table);
    instructions.push_back(std::make_unique<Instructions>());
}

std::unique_ptr <Instructions> Compiler::pop_scope() {
    auto old = symbol_table;
    symbol_table = symbol_table->parent;
    delete old;
    auto res = std::move(instructions.back());
    instructions.pop_back();
    return std::move(res);
}

Iterator Compiler::get_error_pos(Iterator err_pos, int &line) const {
    line = 1;
    Iterator i = start;
    if (i == end) return start;
    Iterator line_start = start;
    while (i != err_pos) {
        bool eol = false;
        if (i != err_pos && *i == '\r')  // CR
        {
            eol = true;
            line_start = ++i;
        }
        if (i != err_pos && *i == '\n')  // LF
        {
            eol = true;
            line_start = ++i;
        }
        if (eol)
            ++line;
        else
            ++i;
    }
    return line_start;
}

std::string Compiler::get_error_line(Iterator err_pos) const {
    Iterator i = err_pos;
    // position i to the next EOL
    while (i != end && (*i != '\r' && *i != '\n')) ++i;
    return std::string(err_pos, i);
}

bool Compiler::consume(const std::string &expected) {
    if (cur.type != TokenType::Reserved ||
        expected.length() != cur.literal.length() ||
        !equal(expected.begin(), expected.end(), cur.literal.begin(),
               cur.literal.end())) {
        return false;
    }
    eat();
    return true;
}

bool Compiler::consume(TokenType type) {
    if (cur.type != type) {
        return false;
    }
    eat();
    return true;
}

void Compiler::check(TokenType type) {
    if (cur.type != type) {
        std::stringstream ss;
        ss << "Expected '" << SRCLANG_TOKEN_ID[static_cast<int>(type)]
           << "' but got '" << cur.literal << "'";
        error(ss.str(), cur.pos);
    }
}

void Compiler::expect(const std::string &expected) {
    if (cur.literal != expected) {
        std::stringstream ss;
        ss << "Expected '" << expected << "' but got '" << cur.literal
           << "'";
        error(ss.str(), cur.pos);
    }
    return eat();
}

void Compiler::expect(TokenType type) {
    if (cur.type != type) {
        std::stringstream ss;
        ss << "Expected '" << SRCLANG_TOKEN_ID[int(type)] << "' but got '"
           << cur.literal << "'";
        error(ss.str(), cur.pos);
    }
    return eat();
}

void Compiler::eat() {
    cur = peek;

    do {
        if (iter == end) {
            peek.type = TokenType::Eof;
            return;
        }
        if (!isspace(*iter)) break;
        iter++;
    } while (true);

    peek.pos = iter;

    auto escape = [&](Iterator &iterator, bool &status) -> char {
        if (*iterator == '\\') {
            char ch = *++iterator;
            iterator++;
            switch (ch) {
                case 'a':
                    return '\a';
                case 'b':
                    return '\b';
                case 'n':
                    return '\n';
                case 't':
                    return '\t';
                case 'r':
                    return '\r';
                case '\\':
                    return '\\';
                case '\'':
                    return '\'';
                case '"':
                    return '"';
                default:
                    error("invalid escape sequence", iterator - 1);
            }
        }
        return *iter++;
    };

    if (*iter == '/' && *(iter + 1) == '/') {
        iter += 2;
        while (*iter != '\n') {
            if (iter == end) {
                peek.type = TokenType::Eof;
                return;
            }
            iter++;
        }
        iter++;
        return eat();
    }

    if (*iter == '"' || *iter == '\'') {
        auto starting = *iter;
        iter++;
        peek.literal.clear();
        bool status = true;
        while (*iter != starting) {
            if (iter == end) {
                error("unterminated string", peek.pos);
            }
            peek.literal += escape(iter, status);
        }
        iter++;
        peek.type = TokenType::String;
        return;
    }

    for (std::string k: {"let", "fun", "return", "class", 
                         "if", "else", "for",
                         "break", "continue", "use", "global", "as",
                         "in", "defer", "native",

            // special operators
                         "#!", "not", "...", ":=",

            // multi char operators
                         "==", "!=", "<=", ">=", ">>", "<<"}) {
        auto dist = distance(k.begin(), k.end());
        if (dist < distance(iter, end) && equal(iter, iter + dist, k.begin(), k.end()) &&
            !isalnum(*(iter + dist))) {
            iter += dist;
            peek.literal = std::string(k.begin(), k.end());
            peek.type = TokenType::Reserved;
            return;
        }
    }

    if (isalpha(*iter) || *iter == '_') {
        do {
            iter++;
        } while (isalnum(*iter) || *iter == '_');
        peek.literal = std::string_view(peek.pos, iter);
        peek.type = TokenType::Identifier;
        return;
    }

    if (ispunct(*iter)) {
        peek.literal = std::string_view(peek.pos, ++iter);
        peek.type = TokenType::Reserved;
        return;
    }

    if (isdigit(*iter)) {
        do {
            iter++;
        } while (isdigit(*iter) || *iter == '.' || *iter == '_');
        if (*iter == 'b' ||
            *iter ==
            'h') {  // include 'b' for binary and 'h' for hexadecimal
            iter++;
        }
        peek.literal = std::string_view(peek.pos, iter);
        peek.type = TokenType::Number;
        return;
    }
    error("unexpected token", iter);
}

Compiler::Precedence Compiler::precedence(std::string tok) {
    static std::map <std::string, Precedence> prec = {
            {":=",  P_Assignment},
            {"=",   P_Assignment},
            {"or",  P_Or},
            {"and", P_And},
            {"&",   P_Land},
            {"|",   P_Lor},
            {"==",  P_Equality},
            {"!=",  P_Equality},
            {">",   P_Comparison},
            {"<",   P_Comparison},
            {">=",  P_Comparison},
            {"<=",  P_Comparison},
            {">>",  P_Shift},
            {"<<",  P_Shift},
            {"+",   P_Term},
            {"-",   P_Term},
            {"*",   P_Factor},
            {"/",   P_Factor},
            {"%",   P_Factor},
            {"not", P_Unary},
            {"-",   P_Unary},
            {".",   P_Call},
            {"[",   P_Call},
            {"(",   P_Call},
    };
    auto i = prec.find(tok);
    if (i == prec.end()) {
        return P_None;
    }
    return i->second;
}

void Compiler::number() {
    bool is_float = false;
    int base = 10;
    std::string number_value;
    if (cur.literal.starts_with("0") && cur.literal.length() > 1) {
        base = 8;
        cur.literal = cur.literal.substr(1);
    }
    for (auto i: cur.literal) {
        if (i == '.') {
            if (is_float) {
                error("multiple floating point detected", cur.pos);
            }
            number_value += '.';
            is_float = true;
        } else if (i == '_') {
            continue;
        } else if (i == 'b') {
            base = 2;
        } else if (i == 'h') {
            base = 16;
        } else if (i == 'o') {
            base = 8;
        } else {
            number_value += i;
        }
    }
    Value val;
    try {
        val = SRCLANG_VALUE_NUMBER(is_float ? stod(number_value) : std::stol(number_value, nullptr, base));
    } catch (std::invalid_argument const &e) {
        error("Invalid numerical value " + std::string(e.what()), cur.pos);
    }

    language->constants.push_back(val);
    emit(OpCode::CONST_, language->constants.size() - 1);
    return expect(TokenType::Number);
}

void Compiler::identifier(bool can_assign) {
    auto iter = std::find(SRCLANG_VALUE_TYPE_ID.begin(),
                          SRCLANG_VALUE_TYPE_ID.end(), cur.literal);
    if (iter != SRCLANG_VALUE_TYPE_ID.end()) {
        emit(OpCode::LOAD, Symbol::Scope::TYPE,
             distance(SRCLANG_VALUE_TYPE_ID.begin(), iter));
        return eat();
    }
    check(TokenType::Identifier);
    auto id = cur;
    eat();
    auto symbol = symbol_table->resolve(id.literal);

    if (can_assign && consume(":=")) {
        if (symbol == std::nullopt) {
            symbol = symbol_table->define(id.literal);
        }
        value(&*symbol);
        emit(OpCode::STORE, symbol->scope, symbol->index);
    } else {
        if (symbol == std::nullopt) {
            error("undefined variable '" + id.literal + "'", id.pos);
        }
        if (can_assign && consume("=")) {
            value(&*symbol);
            emit(OpCode::STORE, symbol->scope, symbol->index);
        } else {
            emit(OpCode::LOAD, symbol->scope, symbol->index);
        }
    }
}

void Compiler::string_() {
    auto string_value = SRCLANG_VALUE_STRING(strdup(cur.literal.c_str()));
    language->memoryManager.heap.push_back(string_value);
    language->constants.push_back(string_value);
    emit(OpCode::CONST_, language->constants.size() - 1);
    return expect(TokenType::String);
}

void Compiler::unary(OpCode op) {
    expression(P_Unary);
    
    emit(op);
}

void Compiler::block() {
    expect("{");
    while (!consume("}")) statement();
}

/// fun '(' args ')' block
void Compiler::function(Symbol *symbol, bool skip_args) {
    bool is_variadic = false;
    auto pos = cur.pos;
    push_scope();
    if (symbol != nullptr) {
        auto freeSymbol = symbol_table->define(*symbol);
        emit(OpCode::SET_SELF, freeSymbol.index);
    }
    int nparam = 0;
    if (!skip_args) {
        expect("(");

        while (!consume(")")) {
            check(TokenType::Identifier);
            nparam++;
            symbol_table->define(cur.literal);
            eat();

            if (consume("...")) {
                expect(")");
                is_variadic = true;
                break;
            }
            if (consume(")")) break;

            expect(",");
        }
    }

    auto fun_debug_info = std::make_shared<DebugInfo>();
    fun_debug_info->filename = filename;
    get_error_pos(pos, fun_debug_info->position);
    auto old_debug_info = debug_info;
    debug_info = fun_debug_info.get();

    block();

    int line;
    get_error_pos(cur.pos, line);

    debug_info = old_debug_info;

    int nlocals = symbol_table->definitions;
    auto free_symbols = symbol_table->free;

    auto fun_instructions = pop_scope();
    if (fun_instructions->last_instruction == OpCode::POP) {
        fun_instructions->pop_back();
        fun_instructions->emit(fun_debug_info.get(), line, OpCode::RET);
    } else if (fun_instructions->last_instruction != OpCode::RET) {
        fun_instructions->emit(fun_debug_info.get(), line,
                               OpCode::CONST_NULL);
        fun_instructions->emit(fun_debug_info.get(), line, OpCode::RET);
    }

    for (auto const &i: free_symbols) {
        emit(OpCode::LOAD, i.scope, i.index);
    }

    static int function_count = 0;
    std::string id;
    if (symbol == nullptr) {
        id = std::to_string(function_count++);
    } else {
        id = symbol->name;
    }

    auto fun = new Function{
            FunctionType::Function, id, std::move(fun_instructions), nlocals, nparam,
            is_variadic,
            fun_debug_info};
    auto fun_value = SRCLANG_VALUE_FUNCTION(fun);
    language->memoryManager.heap.push_back(fun_value);
    language->constants.push_back(fun_value);

    emit(OpCode::CLOSURE, language->constants.size() - 1, free_symbols.size());
}

void Compiler::class_() {
    check(TokenType::Identifier);
    auto class_id = cur.literal;
    eat();
}

/// list ::= '[' (<expression> % ',') ']'
void Compiler::list() {
    int size = 0;
    while (!consume("]")) {
        expression();
        size++;
        if (consume("]")) break;
        expect(",");
    }
    emit(OpCode::PACK, size);
}

/// map ::= '{' ((<identifier> ':' <expression>) % ',') '}'
void Compiler::map_() {
    int size = 0;
    while (!consume("}")) {
        check(TokenType::Identifier);
        language->constants.push_back(SRCLANG_VALUE_STRING(strdup(cur.literal.c_str())));
        emit(OpCode::CONST_, language->constants.size() - 1);
        eat();

        expect(":");

        expression();
        size++;
        if (consume("}")) break;
        expect(",");
    }
    emit(OpCode::MAP, size);
}

void Compiler::prefix(bool can_assign) {
    if (cur.type == TokenType::Number) {
        return number();
    } else if (cur.type == TokenType::String) {
        return string_();
    } else if (cur.type == TokenType::Identifier) {
        return identifier(can_assign);
    } else if (consume("not")) {
        return unary(OpCode::NOT);
    } else if (consume("-")) {
        return unary(OpCode::NEG);
    } else if (consume("[")) {
        return list();
    } else if (consume("{")) {
        return map_();
    } else if (consume("fun")) {
        return function(nullptr);
    } else if (consume("use")) {
        return use();
    } else if (consume("(")) {
        expression();
        return expect(")");
    }

    error("Unknown expression type '" + SRCLANG_TOKEN_ID[int(cur.type)] + "'",
            cur.pos);
}

void Compiler::binary(OpCode op, int prec) {
    int pos = 0;
    switch (op) {
        case OpCode::OR:
            pos = emit(OpCode::CHK, 1, 0);
            break;
        case OpCode::AND:
            pos = emit(OpCode::CHK, 0, 0);
            break;
    }
    expression(prec + 1);
    emit(op);
    if (op == OpCode::OR || op == OpCode::AND) {
        inst()->at(pos + 2) = inst()->size();
    }
}

/// call ::= '(' (expr % ',' ) ')'
void Compiler::call() {
    auto pos = cur.pos;
    int count = 0;
    while (!consume(")")) {
        count++;
        expression();
        if (consume(")")) break;
        expect(",");
    }
    if (count >= UINT8_MAX) {
        error("can't have arguments more that '" + std::to_string(UINT8_MAX) + "'", pos);
    }
    emit(OpCode::CALL, count);
}

/// index ::= <expression> '[' <expession> (':' <expression>)? ']'
void Compiler::index(bool can_assign) {
    int count = 1;
    if (cur.literal == ":") {
        emit(OpCode::CONST_INT, 0);
    } else {
        expression();
    }

    if (consume(":")) {
        count += 1;
        if (cur.literal == "]") {
            emit(OpCode::CONST_INT, -1);
        } else {
            expression();
        }
    }
    expect("]");
    if (can_assign && consume("=") && count == 1) {
        value(nullptr);
        emit(OpCode::SET);
    } else {
        emit(OpCode::INDEX, count);
    }
}

/// subscript ::= <expression> '.' <expression>
void Compiler::subscript(bool can_assign) {
    check(TokenType::Identifier);

    auto string_value = SRCLANG_VALUE_STRING(strdup(cur.literal.c_str()));
    language->memoryManager.heap.push_back(string_value);
    language->constants.push_back(string_value);
    emit(OpCode::CONST_, language->constants.size() - 1);
    eat();

    if (can_assign && consume("=")) {
        value(nullptr);
        emit(OpCode::SET);
    } else {
        emit(OpCode::INDEX, 1);
    }
}

void Compiler::infix(bool can_assign) {
    static std::map <std::string, OpCode> binop = {
            {"+",   OpCode::ADD},
            {"-",   OpCode::SUB},
            {"/",   OpCode::DIV},
            {"*",   OpCode::MUL},
            {"==",  OpCode::EQ},
            {"!=",  OpCode::NE},
            {"<",   OpCode::LT},
            {">",   OpCode::GT},
            {">=",  OpCode::GE},
            {"<=",  OpCode::LE},
            {"and", OpCode::AND},
            {"or",  OpCode::OR},
            {"|",   OpCode::LOR},
            {"&",   OpCode::LAND},
            {">>",  OpCode::LSHIFT},
            {"<<",  OpCode::RSHIFT},
            {"%",   OpCode::MOD},
    };

    if (consume("(")) {
        return call();
    } else if (consume(".")) {
        return subscript(can_assign);
    } else if (consume("[")) {
        return index(can_assign);
    } else if (binop.find(cur.literal) != binop.end()) {
        std::string op = cur.literal;
        eat();
        return binary(binop[op], precedence(op));
    }

    error("unexpected infix operation", cur.pos);
}

void Compiler::expression(int prec) {
    bool can_assign = prec <= P_Assignment;
    prefix(can_assign);

    while ((cur.literal != ";" && cur.literal != "{") &&
           prec <= precedence(cur.literal)) {
        infix(can_assign);
    }
}

/// compiler_options ::= #![<option>(<value>)]
void Compiler::compiler_options() {
    expect("[");

    check(TokenType::Identifier);
    auto option_id = cur.literal;
    auto pos = cur.pos;
    eat();

    auto id = language->options.find(option_id);
    if (id == language->options.end()) {
        error("unknown compiler option '" + option_id + "'", pos);
    }
#define CHECK_TYPE_ID(ty)                                          \
    if (variant_typeid(id->second) != typeid(ty)) {                \
        error("invalid value of type '" +                          \
                  std::string(variant_typeid(id->second).name()) + \
                  "' for option '" + option_id + "', required '" + \
                  std::string(typeid(ty).name()) + "'",            \
              pos);                                                \
    }
    OptionType value;
    if (consume("(")) {
        switch (cur.type) {
            case TokenType::Identifier:
                if (cur.literal == "true" || cur.literal == "false") {
                    CHECK_TYPE_ID(bool);
                    value = cur.literal == "true";
                } else {
                    CHECK_TYPE_ID(std::string);
                    value = cur.literal;
                }
                break;
            case TokenType::String:
                CHECK_TYPE_ID(std::string);
                value = cur.literal;
                break;
            case TokenType::Number: {
                bool is_float = false;
                for (int i = 0; i < cur.literal.size(); i++)
                    if (cur.literal[i] == '.') is_float = true;

                if (is_float) {
                    CHECK_TYPE_ID(float);
                    value = stof(cur.literal);
                } else {
                    CHECK_TYPE_ID(int);
                    value = stoi(cur.literal);
                }
            }
                break;
            default:
                CHECK_TYPE_ID(void);
        }
        eat();
        expect(")");
    } else {
        CHECK_TYPE_ID(bool);
        value = true;
    }
#undef CHECK_TYPE_ID

    if (option_id == "VERSION") {
        if (SRCLANG_VERSION > get<float>(value)) {
            error("Code need srclang of version above or equal to "
                  "'" +
                  std::to_string(SRCLANG_VERSION) + "'",
                  pos);
        }
    } else if (option_id == "SEARCH_PATH") {
        language->options[option_id] =
                std::filesystem::absolute(get<std::string>(value)).string() + ":" +
                get<std::string>(language->options[option_id]);
    } else {
        language->options[option_id] = value;
    }
    return expect("]");
}

/// let ::= 'let' 'global'? <identifier> '=' <expression>
void Compiler::let() {
    bool is_global = symbol_table->parent == nullptr;
    if (consume("global")) is_global = true;

    check(TokenType::Identifier);

    std::string id = cur.literal;
    auto s = is_global ? &language->symbolTable : symbol_table;
    auto symbol = s->resolve(id);
    if (symbol.has_value()) {
        error("Variable already defined '" + id + "'", cur.pos);
    }
    symbol = s->define(id);

    eat();

    expect("=");

    value(&*symbol);

    emit(OpCode::STORE, symbol->scope, symbol->index);
    emit(OpCode::POP);
    return expect(";");
}

void Compiler::return_() {
    expression();
    emit(OpCode::RET);
    return expect(";");
}

void Compiler::patch_loop(int loop_start, OpCode to_patch, int pos) {
    for (int i = loop_start; i < inst()->size();) {
        auto j = OpCode(inst()->at(i++));
        switch (j) {
            case OpCode::CONTINUE:
            case OpCode::BREAK: {
                if (j == to_patch && inst()->at(i) == 0)
                    inst()->at(i++) = pos;
            }
                break;

            default:
                i += SRCLANG_OPCODE_SIZE[int(j)];
                break;
        }
    }
}

/// loop ::= 'for' <expression> <block>
/// loop ::= 'for' <identifier> 'in' <expression> <block>
void Compiler::loop() {
    std::optional <Symbol> count, iter, temp_expr;
    static int loop_iterator = 0;
    static int temp_expr_count = 0;
    if (cur.type == TokenType::Identifier &&
        peek.type == TokenType::Reserved &&
        peek.literal == "in") {
        count = symbol_table->define("__iter_" + std::to_string(loop_iterator++) + "__");
        temp_expr = symbol_table->define("__temp_expr_" + std::to_string(temp_expr_count++) + "__");
        iter = symbol_table->resolve(cur.literal);
        if (iter == std::nullopt) iter = symbol_table->define(cur.literal);

        language->constants.push_back(SRCLANG_VALUE_NUMBER(0));
        emit(OpCode::CONST_, language->constants.size() - 1);
        emit(OpCode::STORE, count->scope, count->index);
        emit(OpCode::POP);
        eat();
        expect("in");
    }

    auto loop_start = inst()->size();
    expression();
    if (iter.has_value()) {
        emit(OpCode::STORE, temp_expr->scope, temp_expr->index);
    }

    int loop_exit;

    if (iter.has_value()) {
        emit(OpCode::SIZE);

        // perform index;
        emit(OpCode::LOAD, count->scope, count->index);
        emit(OpCode::GT);
        loop_exit = emit(OpCode::JNZ, 0);

        emit(OpCode::LOAD, temp_expr->scope, temp_expr->index);
        emit(OpCode::LOAD, count->scope, count->index);
        emit(OpCode::INDEX, 1);
        emit(OpCode::STORE, iter->scope, iter->index);
        emit(OpCode::POP);

        language->constants.push_back(SRCLANG_VALUE_NUMBER(1));
        emit(OpCode::CONST_, language->constants.size() - 1);
        emit(OpCode::LOAD, count->scope, count->index);
        emit(OpCode::ADD);
        emit(OpCode::STORE, count->scope, count->index);

        emit(OpCode::POP);
    } else {
        loop_exit = emit(OpCode::JNZ, 0);
    }

    block();

    patch_loop(loop_start, OpCode::CONTINUE, loop_start);

    emit(OpCode::JMP, loop_start);

    int after_condition = emit(OpCode::CONST_NULL);
    emit(OpCode::POP);

    inst()->at(loop_exit + 1) = after_condition;

    patch_loop(loop_start, OpCode::BREAK, after_condition);
}

void Compiler::use() {
    expect("(");
    auto path = cur;
    expect(TokenType::String);
    expect(")");

    std::stringstream ss(std::get<std::string>(language->options["SEARCH_PATH"]));
    std::string search_path;
    bool found = false;
    while (getline(ss, search_path, ':')) {
        search_path += "/" + path.literal + ".src";
        if (std::filesystem::exists(search_path)) {
            found = true;
            break;
        }
    }
    if (!found) {
        error("missing required module '" + path.literal + "'", path.pos);
    }

    if (std::find(loaded_imports.begin(), loaded_imports.end(), search_path) !=
        loaded_imports.end()) {
        return;
    }
    loaded_imports.push_back(search_path);

    std::ifstream reader(search_path);
    std::string input((std::istreambuf_iterator<char>(reader)),
                      (std::istreambuf_iterator<char>()));
    reader.close();

    auto old_symbol_table = symbol_table;
    symbol_table = new SymbolTable{old_symbol_table};
    Compiler compiler(input.begin(), input.end(),
                      search_path, language);
    compiler.symbol_table = symbol_table;
    try {
        compiler.compile();
    } catch (const std::exception& exception) {
        error("failed to import '" + search_path + "'\n" + exception.what(), cur.pos);
    }

    auto instructions = std::move(compiler.code().instructions);
    instructions->pop_back();  // pop OpCode::HLT

    int total = 0;
    // export symbols
    for (auto i: symbol_table->store) {
        if (i.second.scope == Symbol::Scope::LOCAL &&
            isupper(i.first[0])) {
            language->constants.push_back(SRCLANG_VALUE_STRING(strdup(i.first.c_str())));
            instructions->emit(compiler.global_debug_info.get(), 0, OpCode::CONST_, language->constants.size() - 1);
            instructions->emit(compiler.global_debug_info.get(), 0, OpCode::LOAD, i.second.scope,
                               i.second.index);
            total++;
        }
    }
    int nlocals = symbol_table->definitions;
    auto nfree = symbol_table->free;
    delete symbol_table;
    symbol_table = old_symbol_table;
    instructions->emit(compiler.global_debug_info.get(), 0, OpCode::MAP, total);
    instructions->emit(compiler.global_debug_info.get(), 0,
                       OpCode::RET);

    for (auto const &i: nfree) {
        emit(OpCode::LOAD, i.scope, i.index);
    }

    auto fun = new Function{
            FunctionType::Function, "", std::move(instructions), nlocals, 0, false,
            compiler.global_debug_info};
    auto val = SRCLANG_VALUE_FUNCTION(fun);
    language->memoryManager.heap.push_back(val);
    language->constants.push_back(val);

    emit(OpCode::CLOSURE, language->constants.size() - 1, nfree.size());
    emit(OpCode::CALL, 0);
}

/// condition ::= 'if' <expression> <block> (else statement)?
void Compiler::condition() {
    do {
        expression();
    } while (consume(";"));

    auto false_pos = emit(OpCode::JNZ, 0);
    block();

    auto jmp_pos = emit(OpCode::JMP, 0);
    auto after_block_pos = inst()->size();

    inst()->at(false_pos + 1) = after_block_pos;

    if (consume("else")) {
        if (consume("if")) {
            condition();
        } else {
            block();
        }
    }

    auto after_alt_pos = emit(OpCode::CONST_NULL);
    emit(OpCode::POP);
    inst()->at(jmp_pos + 1) = after_alt_pos;
}

ValueType Compiler::type(std::string literal) {
    auto type = literal;
    auto iter = std::find(SRCLANG_VALUE_TYPE_ID.begin(),
                          SRCLANG_VALUE_TYPE_ID.end(), type);
    if (iter == SRCLANG_VALUE_TYPE_ID.end()) {
        throw std::runtime_error("Invalid type '" + type + "'");
    }
    return SRCLANG_VALUE_AS_TYPE(
            SRCLANG_VALUE_TYPES[distance(SRCLANG_VALUE_TYPE_ID.begin(), iter)]);
};

void Compiler::statement() {
    if (consume("let"))
        return let();
    else if (consume("return"))
        return return_();
    else if (consume(";"))
        return;
    else if (consume("if"))
        return condition();
    else if (consume("for"))
        return loop();
    else if (consume("break")) {
        emit(OpCode::BREAK, 0);
        return;
    } else if (consume("continue")) {
        emit(OpCode::CONTINUE, 0);
        return;
    } else if (consume("defer")) {
        return defer();
    } else if (consume("#!")) {
        return compiler_options();
    }

    expression();
    emit(OpCode::POP);
    return expect(";");
}

/// native ::= 'native' <identifier> ( (<type> % ',') ) <type>
void Compiler::native(Symbol *symbol) {
    auto id = symbol->name;

    if (cur.type == TokenType::Identifier) {
        id = cur.literal;
        eat();
    }
    std::vector <CType> types;
    CType ret_type;

    expect("(");

    while (!consume(")")) {
        check(TokenType::Identifier);
        try {
            types.push_back(get_ctype(cur.literal.c_str()));
        } catch (std::runtime_error const &e) {
            error(e.what(), cur.pos);
        }
        eat();

        if (consume(")")) break;
        expect(",");
    }
    check(TokenType::Identifier);
    try {
        ret_type = get_ctype(cur.literal.c_str());
        eat();
    } catch (std::runtime_error const &e) {
        error(e.what(), cur.pos);
    }

    auto native = new NativeFunction{id, types, ret_type};
    Value val = SRCLANG_VALUE_NATIVE(native);
    language->memoryManager.heap.push_back(val);
    language->constants.push_back(val);
    emit(OpCode::CONST_, language->constants.size() - 1);
    emit(OpCode::STORE, symbol->scope, symbol->index);
}

void Compiler::program() {
    while (cur.type != TokenType::Eof) {
        statement();
    }
}

Compiler::Compiler(Iterator
                   start,
                   Iterator
                   end,
                   const std::string &filename, Language *language)
        : iter{start},
          start{start},
          end{end},
          language{language},
          filename{filename} {
    global_debug_info = std::make_shared<DebugInfo>();
    global_debug_info->filename = filename;
    global_debug_info->position = 0;
    debug_info = global_debug_info.get();
    symbol_table = &language->symbolTable;
    instructions.push_back(std::make_unique<Instructions>());
    eat();
    eat();
}

void Compiler::compile() {
    program();
    emit(OpCode::HLT);
}

void Compiler::value(Symbol *symbol) {
    if (consume("fun")) {
        return function(symbol);
    } else if (symbol != nullptr && consume("native")) {
        return native(symbol);
    }
    return expression();
}

void Compiler::defer() {
    function(nullptr, true);
    emit(OpCode::DEFER);
    return expect(";");
}
