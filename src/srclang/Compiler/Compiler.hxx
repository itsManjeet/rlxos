#ifndef SRCLANG_COMPILER_HXX
#define SRCLANG_COMPILER_HXX

#include <iostream>
#include <sstream>
#include <string>
#include <vector>

#include "../ByteCode/ByteCode.hxx"
#include "../Value/Function.hxx"
#include "../ByteCode/Instructions.hxx"
#include "../Interpreter/MemoryManager/MemoryManager.hxx"
#include "../Language/Options.hxx"
#include "SymbolTable/SymbolTable.hxx"
#include "../Value/Value.hxx"

namespace srclang {
    using Iterator = std::string::const_iterator;

    struct Language;

#define SRCLANG_TOKEN_TYPE_LIST \
    X(Reserved)                 \
    X(Identifier)               \
    X(String)                   \
    X(Number)                   \
    X(Eof)

    enum class TokenType : uint8_t {
#define X(id) id,
        SRCLANG_TOKEN_TYPE_LIST
#undef X
    };

    static const std::vector <std::string> SRCLANG_TOKEN_ID = {
#define X(id) #id,
            SRCLANG_TOKEN_TYPE_LIST
#undef X
    };

    struct Token {
        TokenType type;
        std::string literal;
        Iterator pos;

        friend std::ostream &operator<<(std::ostream &os, const Token &token) {
            os << SRCLANG_TOKEN_ID[static_cast<int>(token.type)] << ":"
               << token.literal;
            return os;
        }
    };

    class Compiler {
    private:
        Language *language{nullptr};
        SymbolTable *symbol_table{nullptr};

        Token cur, peek;
        Iterator iter, start, end;
        std::string filename;
    
        std::vector <std::string> loaded_imports;
        std::vector <std::unique_ptr<Instructions>> instructions;
        DebugInfo *debug_info;
        std::shared_ptr <DebugInfo> global_debug_info;

        Instructions *inst();

        void push_scope();

        std::unique_ptr <Instructions> pop_scope();

        template<typename Message>
        void error(const Message &mesg, Iterator pos) {
            int line;
            Iterator line_start = get_error_pos(pos, line);
            std::stringstream err;
            err << filename << ":" << line << '\n';
            if (pos != end) {
                err << "ERROR: " << mesg << '\n';
                err << " | " << get_error_line(line_start) << '\n'
                             << "   ";
                for (; line_start != pos; ++line_start) err << ' ';
                err << '^';
            } else {
                err << "Unexpected end of file. ";
                err << mesg << " line " << line;
            }
            throw std::runtime_error(err.str());
        }

        Iterator get_error_pos(Iterator err_pos, int &line) const;

        [[nodiscard]] std::string get_error_line(Iterator err_pos) const;

        bool consume(const std::string &expected);

        bool consume(TokenType type);

        void check(TokenType type);

        void expect(const std::string &expected);

        void expect(TokenType type);

        void eat();

        enum Precedence {
            P_None = 0,
            P_Assignment,
            P_Or,
            P_And,
            P_Lor,
            P_Land,
            P_Equality,
            P_Comparison,
            P_Shift,
            P_Term,
            P_Factor,
            P_Unary,
            P_Call,
            P_Primary,
        };

        Precedence precedence(std::string tok);

        template<typename T, typename... Ts>
        int emit(T t, Ts... ts) {
            int line;
            get_error_pos(cur.pos, line);
            return inst()->emit(debug_info, line, t, ts...);
        }

        /// comment ::= '//' (.*) '\n'

        /// number ::= [0-9_.]+[bh]
        void number();

        /// identifier ::= [a-zA-Z_]([a-zA-Z0-9_]*)
        void identifier(bool can_assign);

        /// string ::= '"' ... '"'
        void string_();

        /// unary ::= ('+' | '-' | 'not') <expression>
        void unary(OpCode op);

        /// block ::= '{' <stmt>* '}'
        void block();

        void value(Symbol *symbol);

        /// fun '(' args ')' block
        void function(Symbol *symbol, bool skip_args = false);

        void class_();

        /// native ::= 'native' <identifier> ( (<type> % ',') ) <type>
        void native(Symbol *symbol);

        /// list ::= '[' (<expression> % ',') ']'
        void list();

        /// map ::= '{' ((<identifier> ':' <expression>) % ',') '}'
        void map_();

        /// prefix ::= number
        ///        ::= string
        ///        ::= identifier
        ///        ::= unary
        ///        ::= list
        ///        ::= map
        ///        ::= function
        ///        ::= use
        ///        ::= '(' expression ')'
        void prefix(bool can_assign);

        /// binary ::= expr ('+' | '-' | '*' | '/' | '==' | '!=' | '<' | '>' | '>=' | '<=' | 'and' | 'or' | '|' | '&' | '>>' | '<<' | '%') expr
        void binary(OpCode op, int prec);

        /// call ::= '(' (expr % ',' ) ')'
        void call();

        /// index ::= <expression> '[' <expession> (':' <expression>)? ']'
        void index(bool can_assign);

        /// subscript ::= <expression> '.' <expression>
        void subscript(bool can_assign);

        /// infix ::= call
        ///       ::= subscript
        ///       ::= index
        ///       ::= binary
        void infix(bool can_assign);

        /// expression ::= prefix infix*
        void expression(int prec = P_Assignment);

        /// compiler_options ::= #![<option>(<value>)]
        void compiler_options();

        /// let ::= 'let' 'global'? <identifier> '=' <expression>
        void let();

        /// return ::= 'return' <expression>
        void return_();

        void patch_loop(int loop_start, OpCode to_patch, int pos);

        /// loop ::= 'for' <expression> <block>
        /// loop ::= 'for' <identifier> 'in' <expression> <block>
        void loop();

        /// use ::= 'use' '('  <string> ')'
        void use();

        /// defer ::= 'defer' <function>
        void defer();

        /// condition ::= 'if' <expression> <block> (else statement)?
        void condition();

        /// type ::= 'identifier'
        ValueType type(std::string literal);

        /// statement ::= let
        ///           ::= return
        ///           ::= ';'
        ///           ::= condition
        ///           ::= loop
        ///           ::= break
        ///           ::= continue
        ///           ::= defer
        ///           ::= compiler_options
        ///           ::= expression ';'
        void statement();

        /// program ::= statement*
        void program();

    public:
        Compiler(Iterator start, Iterator end, const std::string &filename, Language *language);

        void compile();

        ByteCode code();

        std::shared_ptr <DebugInfo> debugInfo() { return global_debug_info; }
        
    };

}  // srclang

#endif  // SRCLANG_COMPILER_HXX
