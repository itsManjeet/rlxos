/*
 * Copyright (c) 2024 Manjeet Singh <itsmanjeet1998@gmail.com>.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

#include "Language/Language.hxx"
#include "../common/Application.h"

using namespace srclang;

struct SrcLangApplication : Application {
    SrcLangApplication() : Application("srclang", "Source Programming Language", ": <FILE>") {
        REGISTER_MAIN(SrcLangApplication, main, 0);
        REGISTER_COMMAND(SrcLangApplication, script, "Run script", 1);
    }

    void init() override {
        language = std::make_unique<Language>();
        for (auto const &[key, value]: ctxt.values) {
            if (key.contains('-')) continue;
            language->define(key, SRCLANG_VALUE_SET_REF(SRCLANG_VALUE_STRING((value.c_str()))));
        }
    }

    void script() {
        language->execute(ctxt.args[0]);
    }

    [[noreturn]]
    void main() const {
        std::string line;
        for (;;) {
            std::cout << ">> ";
            std::getline(std::cin, line);
            try {
                auto result = language->execute(line, "<stdin>");
                std::cout << ":: " << SRCLANG_VALUE_GET_STRING(result) << std::endl;
            } catch (const std::exception &exception) {
                std::cout << "ERROR: " << exception.what() << std::endl;
            }
        }
    }


    std::unique_ptr<Language> language;
};

APPLICATION_MAIN(SrcLangApplication)
