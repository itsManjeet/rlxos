# PKGUPD

> PKGUPD is the core package management scheme used in rlxos (2107 builds).

PKGUPD is provide a high level abstraction for managing package in rlxos GNU/Linux. PKGUPD is capable of managing packages both from binary packages and source codes;

PKGUPD is capable to install/building universal AppImage (.app), native packages (.pkg and .rlx), subsystems (.machine) and system images (.img)

# Basic Usage

## Updating system and database
> However upgradation of system packages is restricted with 2200 release and pkgupd-update only manage the AppImages and extra installed package updates.

`sudo pkgupd update`

**Exclude packages from update** via `update.exclude=list,of,packages,`

## Installing package, appimage or machine

`sudo pkgupd install <package-name>`

**Skip dependency checkup** via `installer.depends=false`
**Force reinstallation** via `force=true`
**Different root directory** via `dir.root=/path/to/root`


## Removing packages
> Removal of system packages (or preinstalled packages) is resticted as per the layer-architecture. So pkgupd-remove is usefull for user installed packages and appimages

`sudo pkgupd remove <package-name>`

and then to cleanup unneeded dependencies

`sudo pkgupd autoremove`

## Search package via name or description

`pkgupd search <package-name> or <description>`


## Getting information about package

`pkgupd info <package-name>`

or to print information about specific parameter

`pkgupd info <package-name> info.value=name`

supported parameters are:
- name
- version
- about
- files
- installed.time
- files.count
- repository
- package

or to dump the package information into file

`pkgupd info <package-name> info.dump=/path/to/file`

## Cleanup cache

`/var/cache/pkgupd/` holds the temporary files and cache of downloaded packages

`sudo pkgupd cleanup`