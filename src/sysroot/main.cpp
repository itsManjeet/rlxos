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
#include "Sysroot.h"
#include <memory>

static std::string truncate(const std::string& revision) {
    auto size = revision.size();
    return revision.substr(0, std::min<size_t>(6, size));
}

struct SysrootApp : Application {
    SysrootApp() : Application("sysroot", "Manage system roots safely") {
        REGISTER_COMMAND(SysrootApp, status, "Display system deployments", 0);
        REGISTER_COMMAND(SysrootApp, install, "Install system extensions", -1);
        REGISTER_COMMAND(SysrootApp, remove, "Remove system extensions", -1);
        REGISTER_COMMAND(SysrootApp, list, "List available extensions", 0);
        REGISTER_COMMAND(
                SysrootApp, update, "Check and apply for system updates", 0);
        REGISTER_COMMAND_WITH_NAME(SysrootApp, "switch", switch_,
                "Switch to different update channel", 1);
    }

    void init() override { backend = std::make_unique<Sysroot>(true); }

    void switch_() {
        auto new_channel = ctxt.args[0];
        PROCESS("Switching to " << new_channel);
        backend->switch_(new_channel);
    }

    void update() {
        PROCESS("Checking for remote updates");
        auto changelog = backend->upgrade(true);
        if (changelog) {
            INFO("New updates available")
            std::cout << changelog->changelog << std::endl;

            if (!prompt_ask("Do you want to apply updates")) { return; }

            PROCESS("Applying updates")
            backend->upgrade(false);
        } else {
            INFO("System is already upto date");
        }
    }

    void list() {
        PROCESS("Fetching available extensions")
        auto list = backend->get_available();

        INFO("Found " << list.size() << " extension(s) from remote");

        auto active_deployment = backend->get_active();
        for (auto const& i : list) {
            bool is_installed =
                    std::find_if(active_deployment.extensions.begin(),
                            active_deployment.extensions.end(),
                            [&](const std::pair<std::string, std::string>& p)
                                    -> bool { return i == p.first; }) !=
                    active_deployment.extensions.end();
            std::cout << " - ";
            if (is_installed) {
                MESSAGE(GREEN("✔"), i);
            } else {
                MESSAGE(BLUE("⤓"), i);
            }
        }
    }

    void remove() {
        if (ctxt.args.empty()) {
            throw std::runtime_error("no extension id provided to remove");
        }
        std::vector<std::string> extensions_to_remove;
        auto active_deployment = backend->get_active();
        for (auto const& arg : ctxt.args) {
            bool is_installed =
                    std::find_if(active_deployment.extensions.begin(),
                            active_deployment.extensions.end(),
                            [&](const std::pair<std::string, std::string>& p)
                                    -> bool { return arg == p.first; }) !=
                    active_deployment.extensions.end();
            if (is_installed) { extensions_to_remove.emplace_back(arg); }
        }
        if (extensions_to_remove.empty()) {
            throw std::runtime_error("no extension found for removal");
        }

        PROCESS("Uninstalling following " << extensions_to_remove.size()
                                          << " extension(s)")
        for (auto const& extension : extensions_to_remove) {
            std::cout << " - " << extension << std::endl;
        }

        backend->uninstall(extensions_to_remove);
    }

    void install() {
        if (ctxt.args.empty()) {
            throw std::runtime_error("no package specified");
        }

        PROCESS("Fetching available extensions")
        auto available_extensions = backend->get_available();

        std::vector<std::string> extensions;
        for (auto const& arg : ctxt.args) {
            auto extension = std::find_if(available_extensions.begin(),
                    available_extensions.end(),
                    [&arg](const std::string& ref) -> bool {
                        return ref == arg;
                    });
            if (extension == available_extensions.end()) {
                throw std::runtime_error(
                        "no extension found with id '" + arg + "'");
            }
            extensions.emplace_back(*extension);
        }

        PROCESS("Installing following " << extensions.size() << " extension(s)")
        for (auto const& extension : extensions) {
            std::cout << " - " << extension << std::endl;
        }

        backend->install(extensions);
    }

    void status() {
        INFO("Listing deployments")

        g_autoptr(OstreeDeployment) pending_deployment = nullptr;
        g_autoptr(OstreeDeployment) rolling_deployment = nullptr;

        ostree_sysroot_query_deployments_for(backend->backend, OSNAME,
                &pending_deployment, &rolling_deployment);

        for (auto const& deployment : backend->get_deployments()) {
            std::cout << std::endl;
            if (deployment.is_active)
                std::cout << GREEN("(active)") << "    ";
            else
                std::cout << YELLOW("(inactive)") << "  ";
            std::cout << BOLD(deployment.refspec) << ":"
                      << BLUE(truncate(deployment.revision)) << std::endl;

            if (deployment.refspec.ends_with("/local")) {
                std::cout << "  " << BOLD("MERGED") << "        : "
                          << GREEN("TRUE") << std::endl;
                std::cout << "  " << BOLD("EXTENSIONS") << "    : "
                          << deployment.extensions.size() << std::endl;
                std::cout << "  " << BOLD("CHANNEL") << "       : "
                          << BLUE(deployment.channel) << std::endl;
                std::cout << "  " << BOLD("REVISION") << "      : "
                          << truncate(deployment.base_revision) << std::endl;
                if (ostree_deployment_is_staged(deployment.backend)) {
                    std::cout << "  " << BOLD("STAGING") << "       : "
                              << GREEN("TRUE") << std::endl;
                }
                if (auto unlocked = ostree_deployment_get_unlocked(
                            deployment.backend);
                        unlocked != OSTREE_DEPLOYMENT_UNLOCKED_NONE) {
                    std::cout
                            << "  " << BOLD("UNLOCKED") << "      : "
                            << GREEN(ostree_deployment_unlocked_state_to_string(
                                       unlocked))
                            << std::endl;
                }
                if (ostree_deployment_equal(
                            pending_deployment, deployment.backend)) {
                    std::cout << "  " << BOLD("PENDING") << "      : "
                              << GREEN("TRUE") << std::endl;
                }
                if (ostree_deployment_equal(
                            rolling_deployment, deployment.backend)) {
                    std::cout << "  " << BOLD("ROLLING") << "      : "
                              << GREEN("TRUE") << std::endl;
                }
                size_t spacing = 10;
                for (auto const& extension : deployment.extensions) {
                    if (extension.first.size() > spacing) {
                        spacing = extension.first.size() + 5;
                    }
                }
                for (auto const& extension : deployment.extensions) {
                    std::cout << "   - " << BOLD(extension.first)
                              << std::string(spacing - extension.first.length(), ' ')
                              << " : " << BOLD(truncate(extension.second))
                              << std::endl;
                }
            }
        }
    }

private:
    std::unique_ptr<Sysroot> backend{nullptr};
};

int main(int argc, char** argv) {
    auto app = SysrootApp();
    return app.run(argc, argv);
}