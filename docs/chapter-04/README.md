# PKGUPD

> PKGUPD is the core package management scheme used in rlxos (2107 builds).

PKGUPD is provide a high level abstraction for managing package in rlxos GNU/Linux. PKGUPD is capable of managing packages both from binary packages and source codes;

## Usage

```shell
pkgupd [TASK] <args>..
PKGUPD is a system package manager for rlxos.
Perform system level package transcations like installation, upgradation and removal of packages.

Task:
 - install       Install package from repository
                 Options:
                  - installer.depends=<bool>   # Enable or disable dependency management
                  - force=<bool>               # Force installation of already installed package
                  - installer.triggers=<bool>  # Skip triggers during installation, also include user/group creation
                  - downloader.force=<bool>    # Force redownload of specified package

 - remove        Remove package from system
                 Options:
                  - system.packages=<list>    # Skip System packages for removal

 - sync          Sync local database from server repository
 - info          Display package information of specified package
                 Options:
                  - info.value=<param>        # show particular information value
                  - info.value=installed.time # extra parameter for installed package
                  - info.value=files.count    # extra parameter for installed package

 - search        Search package from repository
 - update        Update non-system packages of system
                 Options:
                  - system.packages=<list>    # Skip all system packages
                  - update.exclude=<list>    # Specify package to exclude from update

 - depends       List all the dependent packages required
                 Options:
                  - depends.all=<bool>    # List all dependent packages including already installed packages

 - inject        Inject package from url or filepath directly into system
                  - Can be used for rlxos .app files or bundle packages

 - meta          Generate meta information for package repository
 - build         Build the specified package either from recipe file or from the source repository.
 - trigger       Execute required triggers and create required users & groups
 - revdep        List the reverse dependency of specified package
 - owner         Search the package who provide specified file.
 - run           Run binaries inside container
                  Options:
                  - run.config=<path>   # Set container configuration

 - cleanup       clean pkgupd cache including:
                  - package cache
                  - source files 
                  - recipe data
 - watchdog      Setup the directory as trigger point for pkgupd
                 Directory in (watchdog.dir) will be inspected
                 for changes, Any package put in that directory
                 will be integrated into the system


Exit Status:
  0 if OK
  1 if process failed.

Full documentation <https://docs.rlxos.dev/pkgupd>
```

## Configurations

pkgupd can intake configration directly from cmdline arguments or from /etc/pkgupd.yml file or can specify configuration file path with config=`<path/to/config>`

```yaml

mirrors:
    - https://rlxos.dev/storage/

repositories:
    - core
    - extra
```

or

```shell
pkgupd sync mirrors=https://rlxos.dev/storage, repository=core,extra
```

### Advance configurations

| Configuration Parameter | Descriptions                                      | Default Value          |
| ----------------------- | ------------------------------------------------- | ---------------------- |
| dir.root                | Specify the root directory for package installing | '/'                    |
| dir.data                | PKGUPD system database path                       | /var/lib/pkgupd/data   |
| dir.cache               | PKGUPD cache directory                            | /var/cache/pkgupd      |
| dir.pkgs                | PKGUPD binary packages cache                      | /var/cache/pkgupd/pkgs |
| dir.pkgs                | PKGUPD binary source code cache                   | /var/cache/pkgupd/src  |
