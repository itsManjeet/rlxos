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

#ifndef PKGUPD_APP_H
#define PKGUPD_APP_H

#include "Colors.h"
#include <map>
#include <optional>
#include <string>
#include <vector>

struct Application {
    struct Context {
        std::vector<std::string> args;
        std::map<std::string, std::string> values;

        std::optional<std::string> operator[](const std::string &id) {
            auto iter = values.find(id);
            if (values.end() == iter) return std::nullopt;
            return iter->second;
        }
    };

#define REGISTER_COMMAND(App, id, help, count)                                         \
    REGISTER_COMMAND_WITH_NAME(App, #id, id, help, count)

#define REGISTER_COMMAND_WITH_NAME(App, id, fun, help, count)                                         \
    handlers[id] = {reinterpret_cast<handler>(&App::fun), help, count}

#define REGISTER_MAIN(App, id, count) REGISTER_COMMAND(App, id, description, count)

    Application(std::string name, std::string description, std::string usage = ": <TASK> <ARGS...>") : name(
            std::move(name)), description(std::move(description)), usage(std::move(usage)) {}

    virtual void init() {}

    void help() {
        std::cout << name << " " << usage << '\n' << description << '\n';
        if (!handlers.empty()) {
            std::cout << "TASKS:" << '\n';
            for (auto const &[id, info]: handlers) {
                if (id == "main") continue;
                std::cout << " - " << id << std::string(10 - id.length(), ' ') << std::get<1>(info) << '\n';
            }
        }
    }

    std::string prompt(const std::string &message, const std::vector<std::string> &available = {"Y", "n"}) {
        if (auto default_prompt = ctxt["skip-prompt"]; default_prompt) {
            return *default_prompt;
        }

        std::cout << message << " ";
        std::string sep;
        for (auto const &c: available) {
            std::cout << sep << c;
            sep = "|";
        }
        std::cout << " ";
        std::getline(std::cin, sep);
        return sep;
    }

    bool prompt_ask(const std::string &message) {
        auto res = prompt(message, {"y", "n"});
        return res == "y";
    }

    int run(int argc, char **argv) {
        handler h = nullptr;
        int count = -1;
        for (int i = 1; i < argc; i++) {
            if (auto arg = std::string(argv[i]); arg.find('=') != std::string::npos) {
                auto idx = arg.find('=');
                ctxt.values[arg.substr(0, idx)] = arg.substr(idx + 1);
            } else if (h == nullptr && handlers.contains(argv[i])) {
                h = std::get<0>(handlers[argv[i]]);
                count = std::get<2>(handlers[argv[i]]);
            } else {
                ctxt.args.emplace_back(argv[i]);
            }
        }

        try {
            if (h == nullptr && !handlers.contains("main")) {
                help();
                return 0;
            }
            if (count != -1 && count != ctxt.args.size()) {
                throw std::runtime_error(
                        "expected " + std::to_string(count) + " but " + std::to_string(ctxt.args.size()) + " provided");
            }

            this->init();
            if (h == nullptr) h = std::get<0>(handlers["main"]);
            (this->*(h))();
        } catch (const std::exception &exception) {
            ERROR("Error: " << exception.what());
            return 1;
        }
        return 0;
    }

protected:
    typedef void (Application::*handler)();

    std::map<std::string, std::tuple<handler, std::string, int>> handlers;

    const std::string name;
    const std::string usage;
    const std::string description;
    Context ctxt;
};

#define APPLICATION_MAIN(id) int main(int argc, char** argv) { return id().run(argc, argv); }
#endif // PKGUPD_APP_H
