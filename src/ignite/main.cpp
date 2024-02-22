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

#include "../common/Application.h"
#include "../external/json.h"
#include "ArchiveManager.h"
#include "Executor.h"
#include "Ignite.h"
#include "../external/Curl.h"

struct IgniteApp : Application {
    IgniteApp() : Application("ignite", "Project Management tool") {
        REGISTER_COMMAND(IgniteApp, status, "Display status of element", 1);
        REGISTER_COMMAND(IgniteApp, build, "Build component from element file", 1);
        REGISTER_COMMAND(IgniteApp, checkout, "Checkout cached component", 2);
        REGISTER_COMMAND(IgniteApp, meta, "Generate metadata", 1);
        REGISTER_COMMAND(IgniteApp, pull, "Pull already built cache from server", 1);
    }

    void init() override {
        auto project_path = ctxt["project-path"].value_or(std::filesystem::current_path().string());
        auto cache_path = ctxt["cache-path"].value_or(project_path + "/build");
        backend = std::make_unique<Ignite>(project_path, cache_path);

        backend->load();
    }

    void pull() {
        auto element = ctxt.args[0];
        std::vector<std::tuple<std::string, Builder::BuildInfo, bool>> status;
        backend->resolve({ctxt.args[0]}, status, true, true, true);

        auto artifact_server = ctxt["artifact-server"];
        if (!artifact_server) {
            artifact_server = backend->config.get<std::string>("artifact-server");
        }

        for (auto &[path, build_info, cached]: status) {
            build_info.cache = backend->hash(build_info);
            auto cache_file = backend->cachefile(build_info);
            auto filename = cache_file.filename();
            for (auto const &ext: {"", ".devel", ".doc", ".dbg"}) {
                if (std::filesystem::exists(cache_file.string() + ext)) continue;
                PROCESS("GETTING " << filename.string() << ext);
                Curl().url(*artifact_server + "/cache/" + filename.string() + ext).download(cache_file.string() + ext);
            }

        }
    }

    void meta() {
        auto file = ctxt.args[0];

        nlohmann::json data;
        auto target_path = std::filesystem::path(file).parent_path();
        std::filesystem::remove_all(target_path / "apps");
        std::filesystem::create_directories(target_path / "apps");

        for (auto [path, build_info]: backend->pool) {
            build_info.cache = backend->hash(build_info);
            auto cache_file = backend->cachefile(build_info);
            if (std::filesystem::exists(cache_file)) {
                auto depends = std::vector<std::string>();
                for (std::filesystem::path depend: build_info.depends) {
                    depends.push_back(depend.replace_extension());
                }

                auto type = build_info.config.get<std::string>("type", "component");

                data.push_back({{"id",          std::filesystem::path(path).replace_extension()},
                                {"version",     build_info.version},
                                {"about",       build_info.about},
                                {"cache",       build_info.cache},
                                {"depends",     depends},
                                {"type",        type},
                                {"integration", build_info.integration},
                                {"backup",      build_info.backup},});
                if (type == "app") {
                    PROCESS("Adding App " << data.back()["id"].get<std::string>());
                    Executor("/bin/tar").arg("-xf").arg(cache_file).arg("-C").arg(target_path / "apps").execute();
                }
            }
        }

        std::ofstream writer(file);
        writer << data;
    }

    void checkout() {
        auto source = ctxt.args[0];
        auto target = ctxt.args[1];
        std::filesystem::create_directories(target);

        std::vector<std::tuple<std::string, Builder::BuildInfo, bool>> status;
        backend->resolve({source}, status);

        auto [path, build_info, cached] = status.back();
        if (!cached) { throw std::runtime_error(path + " not cached yet"); }

        std::vector<std::string> files;
        ArchiveManager::extract(backend->cachefile(build_info), target, files);
    }

    void build() {
        std::vector<std::tuple<std::string, Builder::BuildInfo, bool>> status;
        backend->resolve({ctxt.args[0]}, status, true, true, true);

        int count = 0;
        for (auto &[path, build_info, cached]: status) {
            if (cached) { continue; }
            PROCESS("Building " << path)
            build_info.resolve(backend->config);
            backend->build(build_info);
            count++;
        }
        if (count == 0) {
            INFO("Component already cached")
        }
    }

    void status() {
        std::vector<std::tuple<std::string, Builder::BuildInfo, bool>> status;
        backend->resolve({ctxt.args[0]}, status, true, true, true);
        for (auto const &[path, build_info, cached]: status) {
            if (cached) {
                MESSAGE("      " GREEN("CACHED"), path);
            } else {
                MESSAGE("     " BLUE("WAITING"), path);
            }
        }
    }

private:
    std::unique_ptr<Ignite> backend{nullptr};
};

int main(int argc, char **argv) { return IgniteApp().run(argc, argv); }