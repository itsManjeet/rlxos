# Subsystem 1st Generation
> Subsystem in rlxos are guest system that share the hardware and OS kernel with rlxOS.

## Enable PKGUPD repository
First we need to enable the pkgupd repository to access the prebuilt guest systems.

- Create a new file with super user permission

`sudo vim /etc/pkgupd.yml.d/repos.yml`

- Past the below content in the file

```yaml
repos:
    - core
    - extra
    - apps
    - machine
```

- Refresh PKGUPD database

`sudo pkgupd update`


## Installing Guest System

Install the guest system via pkgupd, In this example we are going to setup `debian-stable` subsystem. Same process can be used for other subsystems too.

`sudo pkgupd install debian-stable`

After the message of successful installation we can boot up the subsystem via machinectl.

## Starting Guest system

`sudo machinectl start debian-stable`

No output for this command means success, and `debian-stable` is booted successfully

> To checkout the logs use `sudo journalctl -xe`

## Login into Guest system

After the successful bootup guest system is ready to login or shell access.

`sudo machinectl shell root@debian-stable`

## List running sub systems

List of currently active subsystems

`machinectl list`

## Enable subsystem to run on every start

`sudo machinectl enable debian-stable`

## Restart subsystem

`sudo machinectl reboot debian-stable`

## Exiting for gest system

Press the `ctrl` and `]` key 3 times to exit the guest system


## Use host Networking

To use host network connection add the following option:
```
/etc/systemd/nspawn/debian-stable.nspawn
---------------------------------
[Network]
VirtualEthernet=no
```


## Enable Graphical apps

`xhost +local:` can be used to share the X server to subsystems

```
$ xhost +local:
$ machinectl shell root@debian-stable -E DISPLAY=${DISPLAY}
```

### 3D Graphics acceleration

To enable accelerated 3d graphics we need to bind /dev/dri

```
/etc/systemd/nspawn/debian-stable.nspawn
----------------------------------------
[Files]
Bind=/dev/dri
```


## Sharing files

Files and directories can be shared with bind mount and/or readonly mounts

```
/etc/systemd/nspawn/debian-stable.nspawn
----------------------------------------
[Files]
Bind=/path/to/shared/directory
```

or

**From host to machine**
`machinectl copy-to debian-stable /path/to/file/in/host /path/in/machine`

**From machine to host**
`machinectl copy-from debian-stable /path/to/file/in/machine /path/in/host`


## Run docker inside machine

> Its not recommends as rlxos itself provide a good support to docker and its have no benifit of using docker inside machine

```
/etc/systemd/nspawn/debian-stable.nspawn
----------------------------------------
[Exec]
SystemCallFilter=add_key keyctl bpf

[Files]
Bind=/dev/fuse
```

