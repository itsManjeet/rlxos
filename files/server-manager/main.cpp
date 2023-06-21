#include "ServerManager.hpp"

int main(int argc, char** argv) {
  if (argc == 1) {
    std::cerr << "No task specified" << std::endl;
    return 1;
  }
  YAML::Node configNode = YAML::LoadFile(
      getenv("CONFIG_FILE") ? getenv("CONFIG_FILE") : "/etc/pkgupd.yml");
  auto config = Configuration::create(configNode);
  ServerManager serverManager(config.get());
  if (!strcmp(argv[1], "sync-stable")) {
    serverManager.SyncStable();
  } else if (!strcmp(argv[1], "sync-testing")) {
    serverManager.SyncTesting();
  } else if (!strcmp(argv[1], "sync")) {
    serverManager.Sync();
  } else if (!strcmp(argv[1], "verify-stable")) {
    serverManager.VerifyStablePackages();
  } else if (!strcmp(argv[1], "verify-testing")) {
    serverManager.VerifyTestingPackages();
  } else {
    std::cerr << "Error! invalid task" << std::endl;
    return 1;
  }
}