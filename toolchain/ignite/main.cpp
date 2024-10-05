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

#include "Ignite.h"
#include <cstring>
#include <functional>
#include <iostream>

std::filesystem::path project_path = std::filesystem::current_path();
std::filesystem::path cache_path;
std::string arch = "x86_64";

int help(Ignite* ignite, const std::vector<std::string>& args) {
    std::cout << R"(Usage: ignite <options> <command> <args...>
Commands:
  build <recipes...>        Build artifact of specified recipes

Options:
  -project-path <path>      Specify project path
  -cache-path <path>        Specify cache path
  -arch <arch>              Specify target device architecture (default: x86_64)
)" << std::endl;

    return 1;
}

int build(Ignite* ignite, const std::vector<std::string>& args) {
    std::vector<Ignite::State> states;
    ignite->resolve(args, states);
    for (auto& [id, recipe, cached] : states) {
        if (!cached) {
            recipe.resolve(ignite->config);
            std::cout << "building " << id << std::endl;
            ignite->build(recipe);
        }
    }
    return 0;
}

int status(Ignite* ignite, const std::vector<std::string>& args) {
    std::vector<Ignite::State> states;
    ignite->resolve(args, states);
    for (auto const& [id, recipe, cached] : states) {
        std::cout << "  " << (cached ? "CACHED " : "WAITING") << "  " << id
                  << std::endl;
    }
    return 0;
}

int main(int argc, char** argv) {

    std::function<int(Ignite*, std::vector<std::string>)> function;
    std::vector<std::string> args;

    for (int i = 1; i < argc; ++i) {
        if (argv[i][0] == '-') {
            if (std::strcmp(argv[i], "-project-path") == 0) {
                project_path = argv[++i];
            } else if (std::strcmp(argv[i], "-cache-path") == 0) {
                cache_path = argv[++i];
            } else if (std::strcmp(argv[i], "-arch") == 0) {
                arch = argv[++i];
            } else {
                std::cerr << "Unknown option: " << argv[i] << std::endl;
                return 1;
            }
        } else if (function == nullptr) {
            if (std::strcmp(argv[i], "build") == 0) {
                function = build;
            } else if (std::strcmp(argv[i], "help") == 0) {
                function = help;
            } else if (std::strcmp(argv[i], "status") == 0) {
                function = status;
            } else {
                std::cerr << "Unknown option: " << argv[i] << std::endl;
                return 1;
            }
        } else {
            args.emplace_back(argv[i]);
        }
    }

    if (cache_path.empty()) { cache_path = project_path / "build" / arch; }

    try {
        Configuration configuration;
        Ignite ignite(configuration, project_path, cache_path, arch);

        if (function == nullptr) { return help(&ignite, args); }

        ignite.load();

        return function(&ignite, args);
    } catch (const std::exception& exception) {
        std::cerr << "ERROR: " << exception.what() << std::endl;
        return 1;
    }
}