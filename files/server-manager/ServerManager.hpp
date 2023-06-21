#ifndef __SERVER_MANAGER_HPP__
#define __SERVER_MANAGER_HPP__

#include <libpkgupd/configuration.hh>
#include <libpkgupd/package-info.hh>

using namespace rlxos::libpkgupd;

class ServerManager {
 private:
  std::string version;
  Configuration* config;
  using PackageInfoList =
      std::map<std::string,
               std::map<std::string, std::shared_ptr<PackageInfo>>>;
  std::string testingPath, stablePath;
  PackageInfoList testingPackages, stablePackages;
  std::vector<std::string> repositories;
  PackageInfoList stableMeta, testingMeta;

  void loadPackages(std::string path, PackageInfoList& list);
  void loadMetas(std::string path, PackageInfoList& list);

  void flushPackages(std::string path, PackageInfoList& list);
  PackageInfoList syncMeta(PackageInfoList& meta, PackageInfoList& packages,
                           bool interactive = false,
                           bool add_all_missing = false,
                           bool add_all_outdated = false);
  int countPackages(PackageInfoList& packages);
  void verifyPackages(std::string path, PackageInfoList& packages);

 public:
  ServerManager(Configuration* config);

  void SyncStable();
  void SyncTesting();
  void Sync();
  void VerifyStablePackages();
  void VerifyTestingPackages();
};

#endif