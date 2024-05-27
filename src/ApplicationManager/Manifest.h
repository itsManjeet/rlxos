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

#ifndef RLXOS_MANIFEST_H
#define RLXOS_MANIFEST_H

#include <filesystem>
#include <vector>

#define KEYS_LIST                                                              \
    X(id)                                                                      \
    X(name)                                                                    \
    X(version)                                                                 \
    X(description)                                                             \
    X(entry)                                                                   \
    X(mimetypes)                                                               \
    X(category)                                                                \
    X(icon)

class Manifest {
public:
    explicit Manifest();

    void parse(const std::filesystem::path& filepath);

#define X(id)                                                                  \
    std::string const& id() const { return m_##id; }
    KEYS_LIST
#undef X
private:
#define X(id) std::string m_##id;
    KEYS_LIST
#undef X
};

#endif // RLXOS_MANIFEST_H
