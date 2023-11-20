# System Updates

## Swupd

`Swupd` - Software Updater Daemon is a `libostree` frontend to manage and apply system updates on demand.

### Check System Updates

You can view changelog and updates information prior to actual deployment with swupd

```
$ sudo swupd upgrade --check
```

### Apply Updates

To apply system updates

```
$ sudo swupd upgrade
```

### Usage

```
swupd [OPTIONS] [COMMAND]
```

### Description

```
Commands:
  upgrade  Upgrade System
  status   Show deployment status
  help     Print this message or the help of the given subcommand(s)

Options:
  -v, --version
      --sysroot <sysroot>  OStree Sysroot [default: /sysroot]
  -h, --help               Print help
```



