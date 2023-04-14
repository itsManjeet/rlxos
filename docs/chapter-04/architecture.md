# PKGUPD Architecture

## Recipe files

PKGUPD uses the `yaml` format files called recipes, that holds the information about the package, its source code, packaging format, license, build instructions etc.

```yaml
id: nano
version: 6.3
about: Pico editor clone with enhancements
depends:
  runtime:
    - file
    - ncurses
license: GPL
category: accessories
tags:
  - cli
  - terminal
  - editor
  - text
  - notepad
sources:
  - https://www.nano-editor.org/dist/v6/nano-{{version}}.tar.xz

configure: >
  --enable-color
  --enable-nanorc
```

Above is the recipe file for `nano` (command line file editor tool).


## Server-To-Local

`pkgupd-build` generates the binary package with `.meta` information for the package (take a look at [core-repository](https://storage.rlxos.dev/core))

these `.meta` files are them merged into `stable` and `testing` versions of `server.stability` level used by the pkgupd user to install and update the binary packages into the local system.


## Type of packages

As PKGUPD is the most extensible package manager, it can handle a packages of type
- Native Packages (.pkg or .rlx) packages the are binary packages the holds the filesystem of a specific application.
- Universal AppImages (.app) universal self-containing applications that work on all linux systems
- Machines (.machine) rlxos subsystem containers
- System Images () System Images are the complete compressed root filesystem of rlxos that mount itself below overlay during boot.

