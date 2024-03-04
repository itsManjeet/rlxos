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

#ifndef PKGUPD_OSTREE_BACKEND_H
#define PKGUPD_OSTREE_BACKEND_H

#include "Deployment.h"
#include <functional>
#include <optional>
#include <ostree.h>
#define OSNAME "rlxos"

struct UpdateInfo {
    std::string changelog;
    size_t size;
};

struct Sysroot {
    OstreeSysroot* backend{nullptr};
    OstreeRepo* repo{nullptr};

    Sysroot(bool use_namespace);

    ~Sysroot();

    std::function<void(double, std::string)> progress =
            [](double, const std::string&) {};

    void install(const std::vector<std::string>& refs);
    void uninstall(const std::vector<std::string>& refs);

    void switch_(const std::string& channel);

    [[nodiscard]] Deployment get_active() const;

    [[nodiscard]] const std::vector<Deployment>& get_deployments() const {
        return deployments;
    }

    [[nodiscard]] std::string version() const;

    [[nodiscard]] std::vector<std::string> get_available() const;

    std::optional<UpdateInfo> upgrade(bool dry_run);

private:
    std::vector<Deployment> deployments;

    void load_deployments();

    std::optional<UpdateInfo> pull(const Deployment& deployment,
            std::vector<std::string>& updated_revisions, bool dry_run = false,
            bool forced = false);

    std::tuple<bool, std::string, std::string> get_changelog(
            const std::string& refspec, const std::string& revision);

    std::optional<UpdateInfo> apply_changes(const Deployment& deployment,
            bool dry_run = false, bool force = false);
};

#endif // PKGUPD_OSTREE_BACKEND_H
