/*
 * Copyright (c) 2023 Manjeet Singh <itsmanjeet1998@gmail.com>.
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

#include "../external/picosha2.h"
#include "Executor.h"
#include <functional>
#include <utility>

const std::vector<std::string> Ignite::SUB_PACKAGES = {"dev", "doc", "devel",};

Ignite::Ignite(std::filesystem::path project_path, std::filesystem::path cache_path) : project_path(
        std::move(project_path)), cache_path(
        cache_path.empty() ? this->project_path / "cache" : std::move(cache_path)) {
    std::string arch;
#ifdef __x86_64__
    arch = "x86_64";
#endif
    auto config_file = this->project_path / ("config-" + arch + ".yml");
    if (!std::filesystem::exists(config_file)) {
        throw std::runtime_error("failed to load configuration file '" + config_file.string() + "'");
    }
    config.update_from_file(config_file);
}

void Ignite::load() {
    PROCESS("Loading elements")
    for (auto const &i: std::filesystem::recursive_directory_iterator(project_path / "elements")) {
        if (i.is_regular_file() && i.path().has_extension() && i.path().extension() == ".yml") {
            auto element_path = std::filesystem::relative(i.path(), project_path / "elements");
            try {
                pool[element_path.string()] = Builder::BuildInfo(i.path(), project_path);
            } catch (const std::exception &exception) {
                throw std::runtime_error("failed to load '" + element_path.string() + " because " + exception.what());
            }
        }
    }
    DEBUG("TOTAL ELEMENTS: " << pool.size());
}

void Ignite::resolve(const std::vector<std::string> &id, std::vector<State> &output, bool devel, bool include_depends,
                     bool include_extra) {
    std::map<std::string, bool> visited;

    std::function<void(const std::string &i)> dfs = [&](const std::string &i) {
        visited[i] = true;
        auto build_info = pool.find(i);
        if (build_info == pool.end()) {
            throw std::runtime_error("MISSING " + i);
        }

        auto depends = build_info->second.depends;
        if (devel) {
            depends.insert(depends.end(), build_info->second.build_time_depends.begin(),
                           build_info->second.build_time_depends.end());
        }
        if (include_extra) {
            if (build_info->second.config.node["include"]) {
                for (auto const &i: build_info->second.config.node["include"]) {
                    depends.push_back(i.as<std::string>());
                }
            }
        }

        if (include_depends) {
            for (const auto &depend: depends) {
                if (visited[depend]) continue;
                try {
                    dfs(depend);
                } catch (const std::exception &exception) {
                    throw std::runtime_error(std::string(exception.what()) + "\n\tTRACEBACK " + i);
                }
            }
        }

        build_info->second.cache = hash(build_info->second);
        auto cached = std::filesystem::exists(cachefile(build_info->second));

        for (auto depend: depends) {
            auto idx = std::find_if(output.begin(), output.end(), [&depend](const auto &val) -> bool {
                return std::get<0>(val) == depend;
            });
            if (idx == output.end()) {
                if (auto in_pool = pool.find(depend); in_pool == pool.end()) {
                    throw std::runtime_error("internal error " + depend + " not in a pool for " + i);
                } else {
                    auto local_build_info = in_pool->second;
                    local_build_info.cache = hash(local_build_info);
                    if (!std::filesystem::exists(cachefile(local_build_info))) {
                        cached = false;
                        break;
                    }
                }

            } else {
                if (!std::get<2>(*idx)) {
                    cached = false;
                    break;
                }
            }
        }

        output.emplace_back(i, build_info->second, cached);
    };

    for (auto const &i: id) { dfs(i); }
}

std::string Ignite::hash(const Builder::BuildInfo &build_info) {
    std::string hash_sum;

    {
        std::stringstream ss;
        ss << build_info.config.node;
        picosha2::hash256_hex_string(ss.str(), hash_sum);
    }

    std::vector<std::string> includes;
    if (build_info.config.node["include"]) {
        for (auto const &i: build_info.config.node["include"]) {
            includes.push_back(i.as<std::string>());
        }
    }

    for (auto const &d: {build_info.depends, build_info.build_time_depends, includes}) {
        for (auto const &i: d) {
            {
                auto depend_build_info = pool.find(i);
                if (depend_build_info == pool.end()) {
                    throw std::runtime_error("missing required element '" + i + " for " + build_info.id);
                }
                std::stringstream ss;
                ss << depend_build_info->second.config.node;
                picosha2::hash256_hex_string(ss.str() + hash_sum, hash_sum);
            }
        }
    }

    return hash_sum;
}

void Ignite::build(const Builder::BuildInfo &build_info) {
    auto container = setup_container(build_info, ContainerType::Build);
    std::shared_ptr<void> _(nullptr, [&container](...) {
        // for (auto const& i :
        // std::filesystem::recursive_directory_iterator(container.host_root)) {
        //     if (i.is_regular_file()) {
        //         if (access(i.path().c_str(), W_OK) != 0) {
        //             std::error_code code;
        //             std::filesystem::permissions(i.path(),
        //             std::filesystem::perms::owner_write, code);
        //         }
        //     }
        // }
        // std::filesystem::remove_all(container.host_root);
        // TODO: std:filesystem failed to clean container host_root
        // completely????
        Executor("/bin/rm").arg("-r").arg("-f").arg(container.host_root).execute();
    });
    std::ofstream logger(cache_path / "logs" / (build_info.package_name(build_info.element_id) + ".log"));
    container.logger = &logger;

    auto package_path = cachefile(build_info);
    auto builder = Builder(config, build_info, container);
    auto subdir = builder.prepare_sources(cache_path / "sources", container.host_root / "build-root");
    if (!subdir) subdir = ".";

    auto build_root =
            std::filesystem::path("build-root") / build_info.config.get<std::string>("build-dir", subdir->string());
    build_root = build_info.resolve(build_root.string(), config);
    try {
        builder.compile_source(build_root, "install-root");
        builder.pack(container.host_root / "install-root", package_path);
    } catch (const std::exception &exception) {
        ERROR(exception.what())
        PROCESS("Entering rescue shell");
        Executor("/bin/sh").container(container).execute();
        throw;
    }
}

Container Ignite::setup_container(const Builder::BuildInfo &build_info, const ContainerType container_type) {
    auto env = std::vector<std::string>{"NOCONFIGURE=1", "HOME=/", "SHELL=/bin/sh", "TERM=dumb", "USER=nishu",
                                        "LOGNAME=nishu", "LC_ALL=C", "TZ=UTC", "SOURCE_DATA_EPOCH=918239400"};
    if (auto n = config.node["environ"]; n) {
        for (auto const &i: n) env.push_back(i.as<std::string>());
    }
    if (auto n = build_info.config.node["environ"]; n) {
        for (auto const &i: n) env.push_back(i.as<std::string>());
    }

    auto host_root = (cache_path / "temp" / build_info.package_name(build_info.element_id));
    std::filesystem::create_directories(host_root);

    std::vector<std::string> capabilities;
    if (build_info.config.node["capabilities"]) {
        for (auto const &i: build_info.config.node["capabilities"]) {
            capabilities.push_back(i.as<std::string>());
        }
    }

    auto container = Container{.environ = env, .binds =
            {{"/sources", cache_path / "sources"},
             {"/cache",   cache_path / "cache"},
             {"/files",   project_path / "files"},
             {"/patches", project_path / "patches"},

            }, .ro_binds = {{"/rlxos",
                             project_path}}, .capabilites = capabilities, .host_root = host_root, .base_dir = project_path, .name = build_info.package_name(
            build_info.element_id),};
    for (auto const &i: {"sources", "cache"}) {
        std::filesystem::create_directories(cache_path / i);
    }
    config.node["dir.build"] = host_root.string();

    // TODO: temporary fix for glib and dependent packages to resolve
    // -Werror=missing-include-dir
    std::filesystem::create_directories(host_root / "usr" / "local" / "include");

    std::vector<State> states;
    auto depends = build_info.depends;
    if (container_type == ContainerType::Build) {
        depends.insert(depends.end(), build_info.build_time_depends.begin(), build_info.build_time_depends.end());
    }

    resolve(depends, states, true, true, false);
    for (auto const &[path, info, cached]: states) {
        integrate(container, info, "");
    }

    if (container_type == ContainerType::Shell) {
        integrate(container, build_info, "");
    }

    // Add Included elements to provided path
    if (build_info.config.node["include"]) {
        states.clear();

        std::vector<std::string> include;
        for (auto const &i: build_info.config.node["include"]) {
            include.push_back(build_info.resolve(i.as<std::string>(), config));
        }

        resolve(include, states, false, build_info.config.get<bool>("include-depends", true), false);

        if (build_info.config.node["include-upon"]) {
            std::vector<State> sub_states;
            resolve({build_info.config.node["include-upon"].as<std::string>()}, sub_states, false, true, false);
            states.erase(std::remove_if(states.begin(), states.end(), [&sub_states](const State &state) -> bool {
                return std::find_if(sub_states.begin(), sub_states.end(), [&state](const State &other_state) -> bool {
                    return std::get<0>(state) == std::get<0>(other_state);
                }) != sub_states.end();
            }), states.end());
        }

        auto include_parts = std::vector<std::string>();
        for (auto const &i: build_info.config.node["include-parts"])
            include_parts.push_back(i.as<std::string>());

        auto include_core = build_info.config.get<bool>("include-core", true);
        for (auto const &[path, info, cached]: states) {
            auto installation_path = std::filesystem::path("install-root") / build_info.package_name();
            installation_path = build_info.config.get<std::string>(build_info.name() + "-include-path",
                                                                   build_info.config.get<std::string>("include-root",
                                                                                                      installation_path.string()));
            integrate(container, info, installation_path, include_parts, !include_core);
        }
    }

    return container;
}

std::filesystem::path Ignite::cachefile(const Builder::BuildInfo &build_info) {
    return cache_path / "cache" / build_info.package_name(build_info.element_id);
}

void Ignite::integrate(Container &container, const Builder::BuildInfo &build_info, const std::filesystem::path &root,
                       std::vector<std::string> extras, bool skip_core) {
    auto container_root =
            container.host_root / (root.has_root_path() ? std::filesystem::path(root.string().substr(1)) : root);
    PROCESS("Integrating " << build_info.id);
    std::filesystem::create_directories(container_root);

    auto cache_file_path = cachefile(build_info);
    for (auto &e: extras) e.insert(e.begin(), '.');
    if (!skip_core) { extras.insert(extras.begin(), {""}); }
    for (auto const &i: extras) {
        auto sub_cache_file_path = cache_file_path.string() + i;
        if (!std::filesystem::exists(sub_cache_file_path)) {
            throw std::runtime_error(build_info.id + " not yet cached at " + sub_cache_file_path);
        }
        try {
            auto extractor = Executor("/bin/tar").arg("-xPhf").arg(sub_cache_file_path).arg("-C").arg(container_root);

            if (root.empty()) {
                extractor.arg("--exclude=./etc/hosts").arg("--exclude=./etc/hostname").arg(
                        "--exclude=./etc/resolve.conf").arg("--exclude=./proc").arg("--exclude=./run").arg(
                        "--exclude=./sys").arg("--exclude=./dev");
            }

            extractor.execute();

        } catch (const std::exception &exception) {
            throw std::runtime_error("failed to integrate " + build_info.package_name(build_info.element_id) + i + " " +
                                     exception.what());
        }
    }

    if (root.empty() && !build_info.integration.empty()) {
        DEBUG("INTEGRATION SCRIPT");
        auto integration_script = build_info.resolve(build_info.integration, config);
        Executor("/bin/sh").arg("-ec").arg(integration_script).container(container).execute();
    } else {
        auto meta_info = build_info;
        meta_info.id = build_info.element_id;

        auto data_dir = container_root / "usr" / "share" / "pkgupd" / "manifest" / meta_info.name();
        std::filesystem::create_directories(data_dir);

        {
            std::ofstream writer(data_dir / "info");
            writer << meta_info.str();
        }
        if (!build_info.integration.empty()) {
            auto integration_script = build_info.resolve(build_info.integration, config);
            {
                std::ofstream writer(data_dir / "integration");
                writer << integration_script;
            }
        }

        std::ofstream writer(data_dir / "files");
        int status = Executor("/bin/tar").arg("-tf").arg(cache_file_path).arg("--exclude=./etc/hosts").arg(
                "--exclude=./etc/hostname").arg("--exclude=./etc/resolve.conf").arg("--exclude=./proc").arg(
                "--exclude=./run").arg("--exclude=./sys").arg("--exclude=./dev").start().wait(&writer);
        writer.close();
        if (status != 0) {
            throw std::runtime_error("failed to read tar files from " + cache_file_path.string());
        }
    }
}
