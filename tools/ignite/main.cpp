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

#include "Executor.h"
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
  status <recipe>           Print if artifact is cached or need to build
  pull <recipe>             Pull artifact cache from artifact-url:
  cache-path <recipe>       Print the cache path of recipe
  update                    Check for package updates
  checkout <recipe> <path>  Checkout artifact at <path>

Options:
  -project-path <path>      Specify project path
  -cache-path <path>        Specify cache path
  -arch <arch>              Specify target device architecture (default: x86_64)
)" << std::endl;

    return 1;
}

int pull(Ignite* ignite, const std::vector<std::string>& args) {
    std::vector<Ignite::State> states;
    ignite->resolve(args, states);
    auto const artifact_url = ignite->config.get<std::string>(
            "artifact-url", "https://repo.rlxos.dev");
    std::filesystem::create_directories(cache_path);

    for (auto& [id, recipe, cached] : states) {
        if (!cached) {
            try {
                recipe.resolve(ignite->config);
            } catch (const std::exception& exception) {
                std::cerr << "ERROR: " << exception.what() << " " << id
                          << std::endl;
                return 1;
            }

            auto hash = ignite->hash(recipe);
            auto server_url = artifact_url + "/cache/" +
                              recipe.package_name(recipe.element_id);
            auto cache_file_path = ignite->cachefile(recipe);
            std::cout << "GET " << server_url << std::endl;
            int status = Executor("/bin/curl")
                                 .arg("-C")
                                 .arg("-")
                                 .arg(server_url)
                                 .arg("-o")
                                 .arg(cache_file_path)
                                 .run();
            if (status != 0) {
                std::cerr << "Error: " << status << std::endl;
                return 1;
            }
        }
    }
    return 0;
}

int get_cache_path(Ignite* ignite, const std::vector<std::string>& args) {
    if (args.size() != 1) {
        std::cerr << "require exactly one argument" << std::endl;
        return 1;
    }

    auto recipe = ignite->get_pool().find(args[0]);
    if (recipe == ignite->get_pool().end()) {
        std::cerr << "no recipe found with id '" << args[0] << "'" << std::endl;
        return 1;
    }

    recipe->second.cache = ignite->hash(recipe->second);
    std::cout << ignite->cachefile(recipe->second) << std::endl;
    return 0;
}

int checkout(Ignite* ignite, const std::vector<std::string>& args) {
    if (args.size() != 2) {
        std::cerr << "require exactly one argument" << std::endl;
        return 1;
    }

    auto recipe = ignite->get_pool().find(args[0]);
    if (recipe == ignite->get_pool().end()) {
        std::cerr << "no recipe found with id '" << args[0] << "'" << std::endl;
        return 1;
    }

    recipe->second.cache = ignite->hash(recipe->second);
    std::filesystem::create_directories(args[1]);

    return Executor("/bin/tar")
            .arg("-xf")
            .arg(ignite->cachefile(recipe->second))
            .arg("-C")
            .arg(args[1])
            .run();
}

int build(Ignite* ignite, const std::vector<std::string>& args) {
    std::vector<Ignite::State> states;
    ignite->resolve(args, states);
    for (auto& [id, recipe, cached] : states) {
        if (!cached) {
            try {
                recipe.resolve(ignite->config);
                std::cout << "building " << id << std::endl;
                ignite->build(recipe);
            } catch (const std::exception& exception) {
                std::cerr << "ERROR: " << exception.what() << " " << id
                          << std::endl;
                return 1;
            }
        }
    }
    return 0;
}

int status(Ignite* ignite, const std::vector<std::string>& args) {
    std::vector<Ignite::State> states;
    ignite->resolve(args, states);
    int total_cached = 0;
    for (auto const& [id, recipe, cached] : states) {
        std::cout << "  " << (cached ? "CACHED " : "WAITING") << "  " << id
                  << std::endl;
        if (cached) ++total_cached;
    }

    std::cout << '\n'
              << "  TOTAL COMPONENTS : " << states.size() << '\n'
              << "  TOTAL CACHED     : " << total_cached << '\n'
              << "  NEED TO BUILD    : " << states.size() - total_cached
              << '\n';
    return 0;
}

auto check_update(Recipe* recipe) -> std::tuple<bool, std::string> {
    if (recipe->sources.empty()) return {false, ""};
    auto url = recipe->sources[0];
    url = url.substr(0, url.find_last_of('/'));

    auto contains = [](const std::string& url,
                            const std::vector<std::string>& s) -> bool {
        for (auto const a : s) {
            if (url.find(a) != std::string::npos) { return true; }
        }
        return false;
    };

    auto get_part = [](const std::string& url, int start,
                            int end) -> std::string {
        std::istringstream stream(url);
        std::string part;
        std::vector<std::string> tokens;

        while (std::getline(stream, part, '/')) { tokens.push_back(part); }

        if (start > 0 && end >= start &&
                end <= static_cast<int>(tokens.size())) {
            std::ostringstream result;
            for (int i = start - 1; i < end; ++i) {
                if (i > start - 1) { result << '/'; }
                result << tokens[i];
            }
            return result.str();
        }

        return "";
    };

    if (contains(url, {"github.com"})) {
        url = "https://github.com/" + get_part(url, 4, 5) + "/tags";
    } else if (contains(url, {"gitlab.com"})) {
        url = "https://gitlab.com/" + get_part(url, 4, 5) + "/tags";
    } else if (contains(url, {"downloads.sourceforge.net"})) {
        url = "https://sourceforge.net/projects/" + get_part(url, 4, 4) +
              "/rss?limit=200";
    } else if (contains(url, {"sourceforge.net"})) {
        url = "https://sourceforge.net/projects/" + get_part(url, 5, 5) +
              "/rss?limit=200";
    } else if (contains(url, {"ftp.gnome.org", "download.gnome.org"})) {
        
    } else if (contains(url, {"archive.xfce.org"})) {
        url = "https://archive.xfce.org/src/" + get_part(url, 5, 5) + "/" +
              recipe->id + "/";
    } else if (contains(url, {"python.org", "pypi.org", "pythonhosted.org",
                                     "pypi.io"})) {
        url = "https://pypi.org/simple/" + recipe->id;
    } else if (contains(url, {"rubygems.org"})) {
        url = "https://rubygems.org/gems/" + recipe->id;
    } else if (contains(url, {"kde.org/stable"})) {
    }

    auto [status, output] =
            Executor("curl").arg("-Lsk").arg(recipe->sources[0]).output();

    return {false, ""};
}

int update(Ignite* ignite, const std::vector<std::string>& args) {
    std::vector<Ignite::State> states;
    ignite->resolve(args, states);
    auto [statu, output] = Executor("curl")
                                   .arg("https://archlinux.org/packages/search/"
                                        "json/?q=cursor&repo=Core&repo=Extra")
                                   .output();
    if (status != 0) {
        std::cerr << "failed to fetch arch api: " << output << std::endl;
        return 1;
    }

    for (auto& [id, recipe, cached] : states) {
        recipe.resolve(ignite->config);
        auto const name = recipe.id;
        auto const version = recipe.version;
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
            } else if (std::strcmp(argv[i], "pull") == 0) {
                function = pull;
            } else if (std::strcmp(argv[i], "cache-path") == 0) {
                function = get_cache_path;
            } else if (std::strcmp(argv[i], "checkout") == 0) {
                function = checkout;
            } else if (std::strcmp(argv[i], "update") == 0) {
                function = update;
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