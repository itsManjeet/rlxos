# Swupd

`Swupd` - Software Updater Daemon is a `libostree` frontend to manage and apply system updates on demand.

### Check System Updates

You can view changelog and updates information prior to actual deployment with swupd

```
$ sudo swupd check
```

### Apply Updates

To apply system updates

```
$ sudo swupd upgrade
```

### Status

Swupd maintains two versions of the operating system
- (:0) Active
- (:1) Previous

You can switch boot into the previous version from the grub screen during boot.

To view these deployment status

```
$ sudo swupd status
```

This view also print certain useful information about the refspec of deployments, unlock status, origin etc.


### Unlock

rlxos is a immutable distribution and you can make any permanent changes into it. But you can apply a safe mutable overlay over the system roots to apply temporary modifications.

```
$ sudo swupd unlock
```

This are temporary changes and revert after reboot.

**Note: Overlay is applied over /usr directory only, modification /etc, /var or any other root directory is still persistent.

### Usage

```
swupd [OPTIONS] [COMMAND]
```

### Description

```
Software Updater daemon

Usage: swupd [OPTIONS] [COMMAND]

Commands:
  upgrade  Upgrade System
  status   Show deployment status
  check    Check for system updates
  unlock   Add safe mutable overlay
  help     Print this message or the help of the given subcommand(s)

Options:
  -v, --version
      --sysroot <sysroot>  OStree Sysroot
  -h, --help               Print help
```



