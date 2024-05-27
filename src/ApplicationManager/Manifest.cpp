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

#include "Manifest.h"

#include <external/json.h>
#include <fstream>

Manifest::Manifest() = default;

void Manifest::parse(const std::filesystem::path& filepath) {
    std::ifstream reader(filepath);
    if (!reader.good()) { throw std::runtime_error("no manifest file found"); }
    auto data = nlohmann::json::parse(reader);

#define X(id) m_##id = data[#id];
    KEYS_LIST
#undef X
#undef KEYS_LIST
}
