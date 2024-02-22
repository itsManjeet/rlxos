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

#include "Builder.h"

#include "../external/Curl.h"
#include "ArchiveManager.h"
#include "Executor.h"
#include <filesystem>
#include <fstream>
#include <optional>
#include <regex>

Builder::BuildInfo::BuildInfo(
        const std::string& filepath, const std::filesystem::path& search_path) {
    config.search_path.push_back(search_path);
    config.node["cache"] = "none";
    update_from_file(filepath);
    if (config.node["build-depends"]) {
        for (auto const& dep : config.node["build-depends"]) {
            build_time_depends.push_back(dep.as<std::string>());
        };
    }
    if (config.node["sources"]) {
        for (auto const& dep : config.node["sources"])
            sources.emplace_back(dep.as<std::string>());
    }
    element_id = std::filesystem::relative(filepath, search_path / "elements")
                         .replace_extension();
}

std::vector<std::string> split(const std::string& str, char del) {
    std::stringstream ss(str);
    std::vector<std::string> l;
    for (std::string s; std::getline(ss, s, del);) { l.push_back(s); }
    return l;
}

std::string replace(std::string v, char old, char n) {
    for (auto& i : v) {
        if (i == old) i = n;
    }
    return v;
}

std::string Builder::BuildInfo::resolve(const std::string& data,
        const std::map<std::string, std::string>& variables) {
    std::regex pattern(R"(\%\{([^}]+)\})");
    std::smatch match;
    std::string result = data;

    while (std::regex_search(result, match, pattern)) {
        if (match.size() > 1) {
            std::string variable = match.str(1);
            auto it = variables.find(variable);
            if (it != variables.end()) {
                result.replace(match[0].first, match[0].second, it->second);
                // TODO: a better way to handle this hack
            } else if (variable.starts_with("version:")) {
                auto data = variable.substr(variable.find_first_of(':') + 1);
                auto version = variables.at("version");
                try {
                    auto nth = std::stoi(data) - 1;
                    int count = 0, position = 0;
                    while (count <= nth) {
                        position += 1;
                        position = version.find('.', position);
                        if (position == std::string::npos) {
                            throw std::string(
                                    "invalid variable value spliting for " +
                                    std::to_string(nth) + "th position");
                        }
                        count++;
                    }
                    result.replace(match[0].first, match[0].second,
                            version.substr(0, position));
                } catch (const std::string& error) {
                    throw std::runtime_error(error);
                } catch (...) {
                    result.replace(match[0].first, match[0].second,
                            replace(version, '.', data[0]));
                }
            } else {
                throw std::runtime_error(
                        "undefined variable '" + variable + "'");
            }
        }
    }
    return result;
}

void Builder::BuildInfo::resolve(
        const Config& global, const std::map<std::string, std::string>& extra) {
    for (auto& source : sources) { source = resolve(source, global, extra); }
}

std::string Builder::BuildInfo::resolve(const std::string& value,
        const Config& global,
        const std::map<std::string, std::string>& extra) const {
    std::map<std::string, std::string> variables = extra;
    if (global.node["variables"]) {
        for (auto const& v : global.node["variables"]) {
            variables[v.first.as<std::string>()] = v.second.as<std::string>();
        }
    }

    if (this->config.node["variables"]) {
        for (auto const& v : this->config.node["variables"]) {
            variables[v.first.as<std::string>()] = v.second.as<std::string>();
        }
    }

    for (auto const& i : this->config.node) {
        if (i.second.IsScalar()) {
            try {
                variables[i.first.as<std::string>()] =
                        i.second.as<std::string>();
            } catch (...) {}
        }
    }

    variables["build-dir"] = "_pkgupd_build_dir";

    return resolve(value, variables);
}

std::optional<std::filesystem::path> Builder::prepare_sources(
        const std::filesystem::path& source_dir,
        const std::filesystem::path& build_root) {
    std::optional<std::filesystem::path> subdir;

    std::filesystem::create_directories(build_root);

    for (auto url : build_info.sources) {
        auto filename = std::filesystem::path(url).filename().string();
        if (auto idx = url.find("::"); idx != std::string::npos) {
            filename = url.substr(0, idx);
            url = url.substr(idx + 2);
        }

        auto filepath = source_dir / filename;
        if (!std::filesystem::exists(filepath)) {
            if (url.starts_with("http")) {
                Executor("/bin/wget")
                        .arg(url)
                        .arg("-O")
                        .arg(filepath.string() + ".tmp")
                        .execute();
                std::filesystem::rename(filepath.string() + ".tmp", filepath);
            } else {
                std::filesystem::copy(
                        (container ? container->base_dir
                                   : std::filesystem::current_path()) /
                                url,
                        filepath,
                        std::filesystem::copy_options::recursive |
                                std::filesystem::copy_options::
                                        overwrite_existing);
            }
        }
        if (ArchiveManager::is_archive(filepath)) {
            std::vector<std::string> files_list;

            ArchiveManager::extract(filepath,
                    build_root / (subdir ? *subdir : std::filesystem::path("")),
                    files_list);
            if (!subdir) {
                std::string dir = files_list.front();
                auto idx = dir.find('/');
                if (idx != std::string::npos) { dir = dir.substr(0, idx); }
                subdir = dir;
            }
        } else {
            std::filesystem::copy_file(filepath,
                    build_root /
                            (subdir ? *subdir : std::filesystem::path("")) /
                            filename,
                    std::filesystem::copy_options::overwrite_existing);
        }
    }
    return subdir;
}

void Builder::compile_source(const std::filesystem::path& build_root,
        const std::filesystem::path& install_root) {
    std::vector<std::string> env;
    if (config.node["environ"]) {
        for (auto const& e : config.node["environ"]) {
            env.push_back(e.as<std::string>());
        }
    }

    if (build_info.config.node["environ"]) {
        for (auto const& e : build_info.config.node["environ"]) {
            env.push_back(e.as<std::string>());
        }
    }
    std::map<std::string, std::string> extra_variables;

    auto resolved_install_root =
            (container ? container->host_root : std::filesystem::path("")) /
            install_root / build_info.package_name();
    auto resolved_build_root =
            (container ? container->host_root : std::filesystem::path("")) /
            build_root;
    extra_variables["install-root"] = std::filesystem::path("/") /
                                      install_root / build_info.package_name();
    extra_variables["build-root"] = std::filesystem::path("/") / build_root;

    if (auto pre_script = build_info.config.get<std::string>("pre-script", "");
            !pre_script.empty()) {
        pre_script = build_info.resolve(pre_script, config, extra_variables);
        PROCESS("Executing pre compilation script")
        DEBUG(pre_script);

        Executor("/bin/sh")
                .arg("-ec")
                .arg(pre_script)
                .path(extra_variables["build-root"])
                .environ(env)
                .container(container)
                .execute();
    }

    if (build_info.config.get<std::string>("build-type", "") == "import") {
        auto source = resolved_build_root /
                      build_info.config.get<std::string>("source", "");
        auto target = resolved_install_root /
                      build_info.config.get<std::string>("target", "");
        std::filesystem::create_directories(target);
        Executor("/bin/cp")
                .arg("-rap")
                .arg(source / ".")
                .arg("-t")
                .arg(target)
                .execute();
    } else {
        auto script = build_info.config.get<std::string>("script", "");
        if (script.empty()) {
            auto compiler = get_compiler(resolved_build_root);
            script = compiler.script;
        }

        script = build_info.resolve(script, config, extra_variables);

        PROCESS("Executing compilation script")
        DEBUG(script);

        if (script.length() > 500) {
            auto script_path = resolved_build_root / "pkgupd_exec_script.sh";
            {
                std::ofstream script_writer(script_path);
                script_writer << script;
            }

            Executor("/bin/sh")
                    .arg("-e")
                    .arg("pkgupd_exec_script.sh")
                    .path(extra_variables["build-root"])
                    .environ(env)
                    .container(container)
                    .execute();

        } else {
            Executor("/bin/sh")
                    .arg("-ec")
                    .arg(script)
                    .path(extra_variables["build-root"])
                    .environ(env)
                    .container(container)
                    .execute();
        }
    }

    if (auto post_script =
                    build_info.config.get<std::string>("post-script", "");
            !post_script.empty()) {
        post_script = build_info.resolve(post_script, config, extra_variables);
        PROCESS("Executing pre compilation script")
        DEBUG(post_script);

        Executor("/bin/sh")
                .arg("-ec")
                .arg(post_script)
                .path(extra_variables["build-root"])
                .environ(env)
                .container(container)
                .execute();
    }

    if (build_info.config.get<bool>("strip", true)) {
        for (auto const& iter : std::filesystem::recursive_directory_iterator(
                     resolved_install_root)) {
            if (!iter.is_regular_file()) continue;
            // if file is executable and writable or
            // if file ends with .so and .a
            // TODO check if it cover all cases
            if (((iter.path().has_extension() &&
                         (iter.path().extension() == ".so" ||
                                 iter.path().extension() == ".a")) ||
                        (access(iter.path().c_str(), X_OK) == 0)) &&
                    access(iter.path().c_str(), W_OK) == 0) {

                auto [status, mime_type] = Executor("/bin/file")
                                                   .arg("-b")
                                                   .arg("--mime-type")
                                                   .arg(iter.path())
                                                   .output();
                if (status != 0) {
                    ERROR("failed to read MIME TYPE for " +
                            iter.path().string() + ": " + mime_type);
                    continue;
                }

                std::vector<std::string> mime_to_strip;
                if (config.node["strip-mimetype"]) {
                    for (auto const& i : config.node["strip-mimetype"]) {
                        mime_to_strip.emplace_back(i.as<std::string>());
                    }
                }

                if (build_info.config.node["strip-mimetype"]) {
                    for (auto const& i :
                            build_info.config.node["strip-mimetype"]) {
                        mime_to_strip.emplace_back(i.as<std::string>());
                    }
                }

                if (std::find(mime_to_strip.begin(), mime_to_strip.end(),
                            mime_type) == mime_to_strip.end()) {
                    continue;
                }

                // Some .so are GNU linker scripts, skip them
                DEBUG("MIME_TYPE: '" << mime_type << "'")

                auto dbg_file_path = iter.path().string() + ".dbg";
                // Copy debugging symbols to dbg directory
                Executor("/bin/objcopy")
                        .arg("--only-keep-debug")
                        .arg(iter.path())
                        .arg(dbg_file_path)
                        .silent()
                        .execute();

                std::string strip_args = "--strip-all";
                if (iter.path().has_extension()) {
                    if (iter.path().extension() == ".a") {
                        strip_args = "--strip-debug";
                    } else {
                        strip_args = "--strip-unneeded";
                    }
                }

                // Strip out the debugging symbols
                Executor("/bin/strip")
                        .arg(strip_args)
                        .arg(iter.path())
                        .execute();

                // Link to the extracted debugging symbols
                Executor("/bin/objcopy")
                        .arg("--add-gnu-debuglink=" +
                                iter.path().filename().string() + ".dbg")
                        .arg(iter.path())
                        .path(iter.path().parent_path())
                        .execute();
            }
        }
    }
}

void Builder::pack(const std::filesystem::path& install_root,
        const std::filesystem::path& package) {
    auto install_root_package = install_root / build_info.package_name();
    auto install_root_devel =
            install_root / (build_info.package_name() + ".devel");
    auto install_root_dbg = install_root / (build_info.package_name() + ".dbg");
    auto install_root_doc = install_root / (build_info.package_name() + ".doc");

    for (auto const& i :
            {install_root_dbg, install_root_devel, install_root_doc}) {
        std::filesystem::create_directories(i);
    }

    std::vector<std::regex> keep_files;
    if (build_info.config.node["keep-files"]) {
        for (auto const& i : build_info.config.node["keep-files"]) {
            keep_files.push_back(std::regex(i.as<std::string>()));
        }
    }

    auto keep_file = [&keep_files](const std::string& filename) -> bool {
        for (auto const& i : keep_files) {
            if (std::regex_match(filename, i)) { return true; }
        }
        return false;
    };

    auto replace_directory = [&](const std::filesystem::path& filepath,
                                     const std::filesystem::path& old_parent,
                                     const std::filesystem::path& new_parent)
            -> std::filesystem::path {
        auto relative_path = std::filesystem::relative(filepath, old_parent);
        return new_parent / relative_path;
    };

    auto move_file = [&](const std::filesystem::path& filepath,
                             const std::filesystem::path& new_path) {
        auto replaced_path =
                replace_directory(filepath, install_root_package, new_path);
        std::filesystem::create_directories(replaced_path.parent_path());
        std::filesystem::rename(filepath, replaced_path);
    };

    for (auto const& devel :
            {"usr/include", "usr/lib/cmake", "usr/lib/pkgconfig"}) {
        if (auto path = install_root_package / devel;
                std::filesystem::exists(path)) {
            move_file(path, install_root_devel);
        }
    }

    for (auto const& dbg : {"usr/src", "usr/lib/debug"}) {
        if (auto path = install_root_package / dbg;
                std::filesystem::exists(path)) {
            move_file(path, install_root_dbg);
        }
    }

    for (auto const& dbg : {"usr/share/doc", "usr/share/man"}) {
        if (auto path = install_root_package / dbg;
                std::filesystem::exists(path)) {
            move_file(path, install_root_doc);
        }
    }

    for (auto const& i : std::filesystem::recursive_directory_iterator(
                 install_root_package)) {
        if (i.is_directory()) {
            if (i.path().empty() &&
                    build_info.config.get<bool>("clean-empty-dir", true)) {
                std::filesystem::remove(i.path());
            }
        } else if (!keep_files.empty() && keep_file(i.path().filename())) {
            continue;
        } else if (i.path().has_extension() && i.path().extension() == ".la") {
            std::filesystem::remove(i.path());
        } else if (i.path().has_extension() && i.path().extension() == ".a") {
            move_file(i.path(), install_root_devel);
        } else if (i.path().has_extension() && i.path().extension() == ".dbg") {
            move_file(i.path(), install_root_dbg);
        }
    }

    PROCESS("Compressing " << build_info.name());

    std::ofstream user_map(install_root / "user-map");
    user_map << "+" << getuid() << " root:0\n"
             << config.get<std::string>("user-map", "") << '\n'
             << build_info.config.get<std::string>("user-map", "") << '\n';
    user_map.close();

    std::ofstream group_map(install_root / "group-map");
    group_map << "+" << getgid() << " root:0\n"
              << config.get<std::string>("group-map", "") << '\n'
              << build_info.config.get<std::string>("group-map", "") << '\n';
    group_map.close();

    for (auto const& i : std::map<std::string, std::string>{
                 {"", install_root_package},
                 {".dbg", install_root_dbg},
                 {".devel", install_root_devel},
                 {".doc", install_root_doc},
         }) {
        Executor("/bin/tar")
                .arg("--zstd")
                .arg("--owner-map=" + (install_root / "user-map").string())
                .arg("--group-map=" + (install_root / "group-map").string())
                .arg("-cPf")
                .arg(package.string() + i.first)
                .arg("-C")
                .arg(i.second)
                .arg(".")
                .execute();
    }
}

Builder::Compiler Builder::get_compiler(
        const std::filesystem::path& build_root) {
    std::string build_type;
    if (build_info.config.node["build-type"]) {
        build_type = build_info.config.node["build-type"].as<std::string>();
    } else {
        for (auto const& [id, compiler] : compilers) {
            if (std::filesystem::exists(build_root / compiler.file)) {
                build_type = id;
                break;
            }
        }
    }

    if (build_type.empty() || !compilers.contains(build_type)) {
        throw std::runtime_error(
                "unknown build-type or failed to detect build-type '" +
                build_type + "' at " + build_root.string());
    }
    return compilers[build_type];
}

Builder::Builder(const Config& config, const Builder::BuildInfo& build_info,
        const std::optional<Container>& container)
        : config{config}, build_info{build_info}, container{container} {
    if (config.node["compiler"]) {
        for (auto const& c : config.node["compiler"]) {
            compilers[c.first.as<std::string>()] = Compiler{
                    c.second["file"].as<std::string>(),
                    c.second["script"].as<std::string>(),
            };
        }
    }
}
