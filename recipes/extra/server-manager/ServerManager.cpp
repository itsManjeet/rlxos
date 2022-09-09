#include "ServerManager.hpp"

#include <filesystem>
#include <fstream>

ServerManager::ServerManager(Configuration* config) : config(config) {
  version = config->get<std::string>("version", "2200");
  stablePath = config->get<std::string>("storage.stable", "/storage/stable") +
               "/" + version + "/pkgs";
  testingPath =
      config->get<std::string>("storage.testing", "/storage/testing") + "/" +
      version + "/pkgs";
  config->get(REPOS, repositories);
}

void ServerManager::loadPackages(std::string path, PackageInfoList& list) {
  if (list.size()) {
    std::cout << "    USING CACHE" << std::endl;
    return;
  }
  //   std::cout << "Loading packages '" << path << "'" << std::endl;
  for (auto const& i : repositories) {
    list[i] = std::map<std::string, std::shared_ptr<PackageInfo>>();
    // std::cout << "  REPOSITORY: " << i << std::endl;
    std::string infoFilePath = path + "/" + i + "/info";
    if (!std::filesystem::exists(infoFilePath)) {
      std::cerr << "Error! " << infoFilePath << " not exists";
      continue;
    }
    YAML::Node node;
    try {
      node = YAML::LoadFile(infoFilePath);
    } catch (std::exception const& exception) {
      std::cerr << "Error! yaml exception " << exception.what() << std::endl;
      continue;
    }

    if (!node["pkgs"]) {
      std::cerr << "Error! no 'pkgs' key found" << std::endl;
      continue;
    }
    int count = 0;
    for (auto const& pkg : node["pkgs"]) {
      count++;
      std::string id =
          pkg["id"] ? pkg["id"].as<std::string>() : std::to_string(count);

      try {
        // std::cout << "  " << id;
        list[i][id] =
            std::make_shared<PackageInfo>(pkg, infoFilePath + ":" + id);
      } catch (std::exception const& exception) {
        std::cerr << "Error! invalid package data '" << id << "', "
                  << exception.what() << std::endl;
        continue;
      }
    }
    // std::cout << std::endl;
  }
}

void ServerManager::loadMetas(std::string path, PackageInfoList& list) {
  if (list.size()) {
    std::cout << "    USING CACHE" << std::endl;
    return;
  }
  for (auto const& repo : repositories) {
    list[repo] = std::map<std::string, std::shared_ptr<PackageInfo>>();
    std::string repoPath = path + "/" + repo;
    for (auto const& meta : std::filesystem::directory_iterator(repoPath)) {
      if (!meta.path().has_extension() || meta.path().extension() != ".meta") {
        continue;
      }
      // std::cout << "  REPOSITORY: " << i << std::endl;
      std::string metaFilePath = meta.path().string();
      if (!std::filesystem::exists(metaFilePath)) {
        std::cerr << "Error! " << metaFilePath << " not exists" << std::endl;
        continue;
      }
      YAML::Node node;
      try {
        node = YAML::LoadFile(metaFilePath);
      } catch (std::exception const& exception) {
        std::cerr << "Error! yaml exception " << exception.what() << std::endl;
        continue;
      }

      auto packageInfo = std::make_shared<PackageInfo>(node, metaFilePath);
      list[repo][packageInfo->id()] = packageInfo;
    }
    // std::cout << std::endl;
  }
}

void ServerManager::flushPackages(std::string path, PackageInfoList& list) {
  for (auto const& repo : repositories) {
    std::string repoPath = path + "/" + repo;
    if (list.find(repo) == list.end()) {
      std::cerr << "missing data for " << repo << std::endl;
      continue;
    }
    YAML::Node node;
    node["pkgs"] = std::vector<YAML::Node>();
    for (auto i : list[repo]) {
      node["pkgs"].push_back(i.second->node());
    }
    std::ofstream writer(path + "/" + repo + "/info");
    if (!writer.is_open()) {
      throw std::runtime_error("failed to open info file for writing");
    }
    writer << node;
    writer.close();
  }
}

int ServerManager::countPackages(PackageInfoList& packages) {
  int count = 0;
  for (auto const& i : packages) {
    count += i.second.size();
  }
  return count;
}

ServerManager::PackageInfoList ServerManager::syncMeta(
    PackageInfoList& meta, PackageInfoList& packages, bool interactive,
    bool add_all_missing, bool add_all_outdated) {
  PackageInfoList updatedPackages;
  for (auto const& repo : repositories) {
    if (packages.find(repo) == packages.end() &&
        meta.find(repo) != meta.end()) {
      packages[repo] = meta[repo];
      updatedPackages[repo] = meta[repo];
      continue;
    }
    if (meta.find(repo) == meta.end()) {
      std::cerr << "missing meta data for " << repo << std::endl;
      continue;
    }
    for (auto i = meta[repo].begin(); i != meta[repo].end(); ++i) {
      auto localIterator = packages[repo].find(i->first);
      if (localIterator == packages[repo].end()) {
        if (!add_all_missing) {
          if (interactive) {
            std::cout << "Do I add " << i->second->id() << " into repository: ";
            char c;
            std::cin >> c;
            if (c != 'y') {
              continue;
            }
          }
        }

        std::cout << " ADDED " << i->first << std::endl;
        packages[repo][i->first] = i->second;
        updatedPackages[repo][i->first] = i->second;
        continue;
      }

      if (localIterator->second->version() != i->second->version()) {
        if (!add_all_outdated) {
          if (interactive) {
            std::cout << "Do I update " << i->second->id() << " from "
                      << i->second->version() << " to "
                      << localIterator->second->version() << " : ";
            char c;
            std::cin >> c;
            if (c != 'y') {
              continue;
            }
          }
        }

        std::cout << "UPDATED " << i->first << " from "
                  << localIterator->second->version() << " -> "
                  << i->second->version() << std::endl;
        packages[repo][i->first] = i->second;
        updatedPackages[repo][i->first] = i->second;
      }
    }
  }
  return updatedPackages;
}

void ServerManager::verifyPackages(std::string path,
                                   PackageInfoList& packages) {
  for (auto const& repo : packages) {
    for (auto const& package : repo.second) {
      std::string packagePath =
          path + "/" + repo.first + "/" + PACKAGE_FILE(package.second);
      if (!std::filesystem::exists(packagePath)) {
        std::cout << "MISSING " << package.first << std::endl;
      }
    }
  }
}

void ServerManager::SyncStable() {
  loadPackages(stablePath, stablePackages);
  loadMetas(stablePath, stableMeta);
  syncMeta(stableMeta, stablePackages, getenv("NON_INTERACTIVE") != nullptr,
           getenv("ADD_ALL_MISSING") != nullptr,
           getenv("ADD_ALL_OUTDATED") != nullptr);
  flushPackages(stablePath, stablePackages);
}
void ServerManager::SyncTesting() {
  std::cout << "SYNCING TESTING" << std::endl;
  loadPackages(testingPath, testingPackages);
  std::cout << "  PACKAGES: " << countPackages(testingPackages) << std::endl;
  loadMetas(testingPath, testingMeta);
  std::cout << "  METAS   : " << countPackages(testingMeta) << std::endl;

  syncMeta(testingMeta, testingPackages, getenv("NON_INTERACTIVE") == nullptr,
           getenv("ADD_ALL_MISSING") != nullptr,
           getenv("ADD_ALL_OUTDATED") != nullptr);
  flushPackages(testingPath, testingPackages);
  std::cout << "SUCCESS" << std::endl;
}

void ServerManager::Sync() {
  std::cout << "LOADING TESTING" << std::endl;
  loadPackages(testingPath, testingPackages);
  std::cout << "  PACKAGES: " << countPackages(testingPackages) << std::endl;
  std::cout << "LOADING STABLE" << std::endl;
  loadPackages(stablePath, stablePackages);
  std::cout << "  PACKAGES: " << countPackages(stablePackages) << std::endl;

  auto updatedPackages = syncMeta(testingPackages, stablePackages,
                                  getenv("NON_INTERACTIVE") == nullptr,
                                  getenv("ADD_ALL_MISSING") != nullptr,
                                  getenv("ADD_ALL_OUTDATED") != nullptr);
  for (auto const& repo : updatedPackages) {
    for (auto const& package : repo.second) {
      auto sourcePackage =
          testingPath + "/" + repo.first + "/" + PACKAGE_FILE(package.second);
      auto destPackage =
          stablePath + "/" + repo.first + "/" + PACKAGE_FILE(package.second);
      std::cout << "  COPY " << sourcePackage << " -> " << destPackage
                << std::endl;
      std::error_code error;
      std::filesystem::copy_file(sourcePackage, destPackage,
                                 std::filesystem::copy_options::update_existing,
                                 error);
      if (error) {
        throw std::runtime_error("failed to copy " + sourcePackage + ", " +
                                 error.message());
      }
    }
  }
  flushPackages(stablePath, stablePackages);
  std::cout << "SUCCESS" << std::endl;
}

void ServerManager::VerifyStablePackages() {
  loadPackages(stablePath, stablePackages);
  verifyPackages(stablePath, stablePackages);
}
void ServerManager::VerifyTestingPackages() {
  loadPackages(testingPath, testingPackages);
  verifyPackages(testingPath, testingPackages);
}