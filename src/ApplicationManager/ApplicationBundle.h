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

#ifndef RLXOS_APPLICATIONBUNDLE_H
#define RLXOS_APPLICATIONBUNDLE_H

#include "Manifest.h"
#include <filesystem>
#include <functional>
#include <vector>

class ApplicationBundle {
public:
    explicit ApplicationBundle(std::filesystem::path bundlePath);

    int run(const std::vector<std::string>& args);

    ~ApplicationBundle();

    ApplicationBundle(const ApplicationBundle&) = delete;

    ApplicationBundle& operator=(const ApplicationBundle&) = delete;

    std::vector<std::string> search(const std::filesystem::path& p,
            const std::function<bool(std::string, bool)>& filter);

    [[nodiscard]] Manifest const* manifest() const { return &m_manifest; }

    void integrate(const std::filesystem::path& sysroot = "/");

    void remove(const std::filesystem::path& sysroot = "/");

private:
    void unmount();

    std::filesystem::path m_bundlePath, m_mountPath;

    Manifest m_manifest;
};

#endif // RLXOS_APPLICATIONBUNDLE_H
