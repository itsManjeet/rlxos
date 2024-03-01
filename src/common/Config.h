#ifndef LIBPKGUPD_CONFIGURATION_HH
#define LIBPKGUPD_CONFIGURATION_HH

#include <filesystem>
#include <fstream>
#include <string>
#include <vector>
#include <yaml-cpp/yaml.h>

struct Config {
    YAML::Node node;

    Config() = default;

    std::vector<std::filesystem::path> search_path;

    void update_from_args(
            int argc, char** argv, std::vector<std::string>& args) {
        for (int i = 1; i < argc; i++) {
            std::string arg = argv[i];
            auto idx = arg.find_first_of('=');
            if (idx != std::string::npos) {
                auto var = arg.substr(0, idx);
                auto val = arg.substr(idx + 1);
                if (val.find(',') != std::string::npos) {
                    std::stringstream ss(val);
                    for (std::string s; std::getline(ss, s, ',');) {
                        push(var, s);
                    }
                } else if (is_number(val)) {
                    set(val, std::stod(val));
                } else if (is_bool(val)) {
                    set(val, val == "true");
                } else {
                    set(var, val);
                }
            } else {
                args.emplace_back(arg);
            }
        }
    }

    void update_from_file(const std::string& filepath) {
        std::ifstream reader(filepath);
        if (!reader.good()) {
            throw std::runtime_error("failed to read file '" + filepath + "'");
        }
        std::string content((std::istreambuf_iterator<char>(reader)),
                (std::istreambuf_iterator<char>()));
        update_from(content, filepath);
    }

    void update_from(
            const std::string& data, const std::string& filepath = {}) {
        auto new_node = YAML::Load(data);
        node = Merge(node, new_node);
        if (new_node["merge"]) {
            for (auto const& i : new_node["merge"]) {
                try {
                    auto path = std::filesystem::path(filepath).parent_path() /
                                i.as<std::string>();
                    if (std::filesystem::exists(path)) {
                        update_from_file(
                                std::filesystem::path(filepath).parent_path() /
                                i.as<std::string>());
                    } else {
                        bool found = false;
                        for (auto const& p : search_path) {
                            if (std::filesystem::exists(
                                        p / i.as<std::string>())) {
                                update_from_file(p / i.as<std::string>());
                                found = true;
                                break;
                            }
                        }
                        if (!found) {
                            throw std::runtime_error(
                                    "missing required file to merge '" +
                                    i.as<std::string>() + "'");
                        }
                    }

                } catch (const std::exception& exception) {
                    throw std::runtime_error("failed to load " + filepath +
                                             " because " + exception.what() +
                                             " to merge");
                }
            }
        }
    }

    template <typename T> T get(const std::string& key, T fallback) const {
        if (node[key]) { return node[key].as<T>(); }
        return fallback;
    }

    template <typename T> T get(const std::string& key) const {
        if (node[key]) { return node[key].as<T>(); }
        throw std::runtime_error("missing required key '" + key + "'");
    }

    template <typename T> void set(const std::string& key, T value) {
        node[key] = value;
    }

    template <typename T> void push(const std::string& key, T value) {
        if (!node[key]) { node[key] = {}; }
        node[key].push_back(value);
    }

private:
    static bool is_number(const std::string& s) {
        for (auto c : s) {
            if (!(isdigit(c) || c == '.')) { return false; }
        }
        return true;
    }

    static bool is_bool(const std::string& s) {
        return s == "true" || s == "false";
    }

    static YAML::Node Merge(const YAML::Node& a, const YAML::Node& b) {
        if (a.IsNull())
            return b;
        else if (a.IsMap() && b.IsMap()) {
            YAML::Node merged = a;
            for (auto const& i : b) {
                auto key = i.first.as<std::string>();
                if (a[key]) {
                    merged[key] = Merge(a[key], i.second);
                } else {
                    merged[key] = i.second;
                }
            }
            return merged;
        } else if (a.IsSequence() && b.IsSequence()) {
            YAML::Node merged = a;
            for (const auto& elem : b) { merged.push_back(elem); }
            return merged;
        } else if (a.IsScalar() && b.IsScalar()) {
            return a;
        } else {
            std::stringstream ss;
            ss << a;
            throw std::runtime_error("Can't handle other type: " + ss.str());
        }
    }
};

#endif
