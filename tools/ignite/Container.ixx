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
module;

#include <filesystem>
#include <string>
#include <vector>

export module ignite:Container;

export struct Container
{
    const std::string runtime{"/bin/bwrap"};
    std::string image{};
    std::vector<std::string> environ;
    std::vector<std::pair<std::string, std::string>> binds;
    std::vector<std::string> capabilities;

    std::filesystem::path host_root;
    std::filesystem::path base_dir;
    std::string name;
    std::ostream* logger;

    [[nodiscard]] std::vector<std::string> args() const
    {
        std::vector<std::string> a = {
            "/bin/bwrap",
            "--bind",
            host_root,
            "/",
            "--proc",
            "/proc",
            "--dev",
            "/dev",
            "--ro-bind",
            "/etc/resolv.conf",
            "/etc/resolv.conf",
            "--unshare-all",
            "--share-net",
            "--uid",
            "0",
            "--gid",
            "0",
            "--die-with-parent",
        };

        for (const auto& [dest, source] : binds)
        {
            a.insert(a.end(), {"--bind", source, dest});
        }

        for (const auto& c : capabilities)
        {
            a.insert(a.end(), {"--cap-add", c});
        }

        for (const auto& e : environ)
        {
            const auto idx = e.find('=');
            auto key = e.substr(0, idx);
            auto value = e.substr(idx + 1);
            a.insert(a.end(), {"--setenv", key, value});
        }

        return a;
    }
};
