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

#include <yaml-cpp/yaml.h>

#include <filesystem>
#include <fstream>
#include <string>
#include <vector>

export module ignite:Configuration;

YAML::Node merge(const YAML::Node& a, const YAML::Node& b)
{
    if (a.IsNull())
        return b;

    if (a.IsMap() && b.IsMap())
    {
        YAML::Node merged = a;
        for (const auto& i : b)
        {
            if (const auto key = i.first.as<std::string>(); a[key])
            {
                merged[key] = merge(a[key], i.second);
            }
            else
            {
                merged[key] = i.second;
            }
        }
        return merged;
    }

    if (a.IsSequence() && b.IsSequence())
    {
        YAML::Node merged = a;
        for (const auto& elem : b)
        {
            merged.push_back(elem);
        }
        return merged;
    }

    if (a.IsScalar() && b.IsScalar())
    {
        return a;
    }

    std::stringstream ss;
    ss << a;
    throw std::runtime_error("Can't handle other type: " + ss.str());
}

export struct Configuration
{
    YAML::Node node;

    Configuration() = default;

    std::vector<std::filesystem::path> search_path;

    void update_from_file(const std::string& filepath)
    {
        std::ifstream reader(filepath);
        if (!reader.good())
        {
            throw std::runtime_error("failed to read file '" + filepath + "'");
        }
        std::string content((std::istreambuf_iterator<char>(reader)),
                            (std::istreambuf_iterator<char>()));
        update_from(content, filepath);
    }

    void update_from(const std::string& data, const std::string& filepath = {})
    {
        auto new_node = YAML::Load(data);
        node = merge(node, new_node);
        if (new_node["merge"])
        {
            for (const auto& i : new_node["merge"])
            {
                try
                {
                    auto path = std::filesystem::path(filepath).parent_path() /
                                i.as<std::string>();
                    if (std::filesystem::exists(path))
                    {
                        update_from_file(
                            std::filesystem::path(filepath).parent_path() /
                            i.as<std::string>());
                    }
                    else
                    {
                        bool found = false;
                        for (const auto& p : search_path)
                        {
                            if (std::filesystem::exists(
                                    p / i.as<std::string>()))
                            {
                                update_from_file(p / i.as<std::string>());
                                found = true;
                                break;
                            }
                        }
                        if (!found)
                        {
                            throw std::runtime_error(
                                "missing required file to merge '" +
                                i.as<std::string>() + "'");
                        }
                    }
                }
                catch (const std::exception& exception)
                {
                    throw std::runtime_error(
                        "failed to load " + filepath + " because " +
                        exception.what() + " to merge");
                }
            }
        }
    }

    template <typename T>
    T get(const std::string& key, T fallback) const
    {
        if (node[key])
        {
            return node[key].as<T>();
        }
        return fallback;
    }

    template <typename T>
    T get(const std::string& key) const
    {
        if (node[key])
        {
            return node[key].as<T>();
        }
        throw std::runtime_error("missing required key '" + key + "'");
    }

    template <typename T>
    void set(const std::string& key, T value)
    {
        node[key] = value;
    }

    template <typename T>
    void push(const std::string& key, T value)
    {
        if (!node[key])
        {
            node[key] = {};
        }
        node[key].push_back(value);
    }
};
