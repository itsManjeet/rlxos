#include "MetaInfo.h"

#include "../common/Config.h"
#include <fstream>

void MetaInfo::update_from_data(const std::string &data, const std::string &filepath) {
    config.update_from(data, filepath);

    id = config.get<std::string>("id");
    version = config.get<std::string>("version");
    about = config.get<std::string>("about", "");
    cache = config.get<std::string>("cache");

    if (config.node["depends"]) {
        for (auto const &dep: config.node["depends"]) {
            depends.emplace_back(dep.as<std::string>());
        }
    }
    if (config.node["backup"]) {
        for (auto const &b: config.node["backup"])
            backup.push_back(b.as<std::string>());
    }
    if (config.node["integration"]) {
        integration = config.node["integration"].as<std::string>();
    }
}

std::string MetaInfo::name() const {
    auto name = this->id;
    for (auto &c: name)
        if (c == '/') c = '-';
    return name;
}

std::string MetaInfo::package_name(std::string eid) const {
    if (eid.empty()) eid = id;
    for (auto &c: eid)
        if (c == '/') c = '-';
    return eid + "-" + version + "-" + cache + ".pkg";
}

std::string MetaInfo::str() const {
    std::stringstream ss;
    ss << "id: " << id << "\n";

    ss << "version: " << version << "\n" << "about: " << about << "\n" << "cache: " << cache << "\n";

    if (!depends.empty()) {
        ss << "depends:\n";
        for (auto const &i: depends)
            ss << "- " << std::filesystem::path(i).replace_extension() << "\n";
    }

    if (!backup.empty()) {
        ss << "backup:\n";
        for (auto const &i: backup) ss << "- " << i << "\n";
    }

    if (!integration.empty()) {
        ss << "script: |-\n";
        std::string line;
        std::stringstream script(integration);
        while (std::getline(script, line)) { ss << "  " << line << '\n'; }
        ss << std::endl;
    }

    return ss.str();
}

void MetaInfo::update_from_file(const std::string &filepath) {
    std::ifstream reader(filepath);
    if (!reader.good())
        throw std::runtime_error("failed to read file '" + filepath + "'");
    update_from_data(std::string((std::istreambuf_iterator<char>(reader)), (std::istreambuf_iterator<char>())),
                     filepath);
}
