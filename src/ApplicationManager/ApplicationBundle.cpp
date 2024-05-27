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

#include "ApplicationBundle.h"

#include <algorithm>
#include <fstream>
#include <iostream>
#include <random>
#include <sys/stat.h>

static inline std::string randomString(int size) {
    static char charset[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
            'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
            'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
            'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
            'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'};
    std::default_random_engine rng(std::random_device{}());
    std::uniform_int_distribution<> dist(
            0, (sizeof(charset) / sizeof(charset[0])) - 1);
    std::string str(size, 0);
    std::generate_n(
            str.begin(), size, [&]() -> char { return charset[dist(rng)]; });
    return str;
}

ApplicationBundle::ApplicationBundle(std::filesystem::path bundlePath)
        : m_bundlePath(std::move(bundlePath)) {
    m_mountPath = std::filesystem::temp_directory_path() /
                  ("bundle-" + randomString(10));
    std::filesystem::create_directories(m_mountPath);
    std::stringstream ss;
    ss << "squashfuse " << m_bundlePath << " " << m_mountPath;

    int status = WEXITSTATUS(system(ss.str().c_str()));
    if (status != 0) {
        std::filesystem::remove_all(m_mountPath);
        throw std::runtime_error("failed to mount application bundle");
    }

    try {
        m_manifest.parse(m_mountPath / "manifest.json");
    } catch (...) {
        unmount();
        throw;
    }
}

ApplicationBundle::~ApplicationBundle() { unmount(); }

int ApplicationBundle::run(const std::vector<std::string>& args) {
    auto bin = m_mountPath / m_manifest.entry();
    if (!std::filesystem::exists(bin)) {
        throw std::runtime_error("no command exist at '" + bin.string() + "'");
    }

    std::stringstream ss;

    auto expandEnv = [&](const std::string& key,
                             const std::string& path) -> std::string {
        const std::string env = getenv(key.c_str()) ? getenv(key.c_str()) : "";
        return key + "=" + (m_mountPath / path).string() + ":" + env;
    };

    ss << "env " << expandEnv("PATH", "bin") << " "  //
       << expandEnv("LD_LIBRARY_PATH", "lib") << " " //
       << expandEnv("XDG_DATA_DIRS", "share") << " " //
       << expandEnv("GSETTINGS_SCHEMA_DIR", "share/glib-2.0/schemas") << " "
       << bin;

    for (auto const& arg : args) { ss << " " << arg; }

    return WEXITSTATUS(system(ss.str().c_str()));
}

std::vector<std::string> ApplicationBundle::search(
        const std::filesystem::path& p,
        const std::function<bool(std::string, bool)>& filter) {
    std::vector<std::string> files;
    for (auto const& dir :
            std::filesystem::recursive_directory_iterator(m_mountPath / p)) {
        if (filter(dir.path().string(), dir.is_directory())) {
            files.emplace_back(m_mountPath / dir.path());
        }
    }
    return files;
}
void ApplicationBundle::integrate(const std::filesystem::path& sysroot) {
    auto bin = sysroot / "bin" /
               std::filesystem::path(m_manifest.entry()).filename();

    auto datadir = sysroot / "share";
    auto desktopfile =
            datadir / "applications" / (m_manifest.name() + ".desktop");
    auto iconfile = datadir / "icons" /
                    std::filesystem::path(m_manifest.icon()).filename();

    for (auto const& dir : {bin.parent_path(), desktopfile.parent_path(),
                 iconfile.parent_path()}) {
        std::filesystem::create_directories(dir);
    }

    if (std::filesystem::exists(bin)) std::filesystem::remove(bin);

    std::filesystem::create_symlink(m_bundlePath, bin);
    std::filesystem::copy_file(m_mountPath / m_manifest.icon(), iconfile,
            std::filesystem::copy_options::overwrite_existing);

    std::ofstream writer(desktopfile);
    writer << "[Desktop Entry]\n"
           << "Name=" << m_manifest.name() << "\n"
           << "Type=Application\n"
           << "Exec=ApplicationManager exec " << m_bundlePath.string() << "\n"
           << "Icon=" << iconfile.filename().string() << "\n"
           << "Comment=" << m_manifest.description() << "\n"
           << "Terminal=false\n"
           << "X-RLXOS-BUNDLE=true\n";
    if (!m_manifest.mimetypes().empty()) {
        writer << "MimeType=" << m_manifest.mimetypes() << "\n";
    }
    if (!m_manifest.category().empty()) {
        writer << "Categories=" << m_manifest.category() << "\n";
    }

    writer << "\n[Desktop Action uninstall]\n"
           << "Name=Uninstall " << m_manifest.name() << "\n"
           << "Exec=ApplicationManager remove " << m_bundlePath.string()
           << "\n";

    writer.close();
}

void ApplicationBundle::remove(const std::filesystem::path& sysroot) {
    auto bin = sysroot / "bin" /
               std::filesystem::path(m_manifest.entry()).filename();

    auto datadir = sysroot / "share";
    auto desktopfile =
            datadir / "applications" / (m_manifest.name() + ".desktop");
    auto iconfile = datadir / "icons" /
                    std::filesystem::path(m_manifest.icon()).filename();

    for (auto const& f : {bin, desktopfile, iconfile}) {
        std::filesystem::remove(f);
    }
}

void ApplicationBundle::unmount() {
    if (WEXITSTATUS(system(("umount " + m_mountPath.string()).c_str())) == 0) {
        std::filesystem::remove_all(m_mountPath);
    }
}
