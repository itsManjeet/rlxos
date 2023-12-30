# PKGUPD System (Unlocked)

You might already be familiar with the PKGUPD system, which operates as a traditional package-based system akin to apt-like package managers.

PKGUPD provides a command-line interface for managing system component transactions, encompassing installation, upgrading, and uninstallation of components.

## Update

The **update** command is utilized to check and update outdated components currently installed in the system. New packages are installed to fulfill the sub-dependencies of existing packages if changes occur.

`pkgupd update`

## Install, Remove

Perform the requested action on one or more components specified via `component-id`.

`pkgupd install/remove  <component-id...>`

## Search

The **search** functionality allows users to explore components using specific term(s) in the component ID or description. The search is conducted solely within the remote package list.

`pkgupd search <query>`

## Info

The **info** command displays information about the component, including its dependencies and cache ID.

`pkgupd info <component-id>`


## All Avaiable Options

```
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
 - search        Search package from repository
 - update        Update non-system packages of system
                 Options:
                  - system.packages=<list>    # Skip all system packages
                  - update.exclude=<list>    # Specify package to exclude from update

 - depends       List all the dependent packages required
                 Options:
                  - depends.all=<bool>    # List all dependent packages including already installed packages

 - trigger       Execute required triggers and create required users & groups
 - owner         Search the package who provide specified file.
 - build         Build the PKGUPD component from element file
 - cleanup       clean pkgupd cache including:
                  - package cache
                  - source files 
                  - recipe data
 - ignite        Project Build tool
 - cachefile     print the cache file name
 - autoremove    Cleanup unneeded packages from system

Exit Status:
  0 if OK
  1 if process failed.

```