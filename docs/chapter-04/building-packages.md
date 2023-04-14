# Building packages

> Its alway recommended to build packages inside rlxos-devel container/docker

To build package for rlxos we first need to write a recipe file. (read [architecture](architecture.md) to more about it)

recipe file must contains atlest `id`, `version` and `about` for the package

## Basic Information

**id** unique name to the package
**version** application version packed
**about** a short description of package.

```yaml
id: sample-package
version: 0.0.1
about: A sample package for demonstration
```


## Source Code

Then we need to specify the list of source files accessible via http, https, ftp or file protocols.


```yaml
sources:
    - https://url.com/for/package-0.0.1.tar.gz
    - new-name-0.0.2.tar.gz::https://url.com/for/package2-0.0.1.tar.gz
```


## Compilation

Now we have the package information and source code and this infromation is more than enough in most of the cases as PKGUPD is intelligent enough to extract and autodetect the build tools for the source code and automatically compile it.

Sometime the source code is inside the sub-directory of source package tarball, to tell pkgupd to use specifiy subdirectory inside the source code.

```yaml
build-dir: package-0.0.1/source/code
```

PKGUPD can detect and autobuild following build-tools
- CMakeLists.txt (cmake)
- Makefile (makefile)
- configure (autoconf)
- setup.py (pysetup)
- meson.build (meson)
- cargo.toml  (cargo)
- go.mod (go)

but some source code can have multiple build-tools and to specify pkgupd to use some specific tool

```yaml
build-type: cmake
```

PKGUPD manage the configuration, compile time and installation flags and user can append its custom flags too.

```yaml
configure: >
    --with-documentation
    --without-nls

compile: make-docs

install: install-docs PREFIX=/usr
```

To override pkgupd configuration flags specify the `--prefix` in meson, pysetup and autoconf and `-DCMAKE_INSTALL_PREFIX` in cmake.

## Packaging

Pkgupd currently supports zstd compressed tarballs (and based machine) and squashfs packaging formats. To specify packaging format and package type

```yaml
type: pkg
```

Supported types are:

- pkg
- app
- machine
- system

Each package type have some specific externsions which we check later.

## Dependencies

Package might expect to have some libraries and tools to preinstalled during builing and installations.

```yaml
depends:
    runtime:
        - package1
        - package2
    buildtime:
        - package3
        - package4
```

## Pre/Post scripts

Process to be done before and after compilation of package

```yaml
pre-script: |
    patch -Np1 -i /path/to/file.patch

post-script: |
    rm -r ${pkgupd_pkgdir}/usr/doc/
```


## Including packages

PKGUPD can include package within the package itself and these are avaiable during the compilation.

```yaml
include:
    - some-runtimes
    - other-runtime
```
included packages can have dependencies and that can be managed with

```yaml
include.depends: false
```

meta data for included packages are store in /usr/share/{{id}}/included/ and can be modified with

```yaml
include.path: /var/lib/pkgupd/data
```


## Installation script

This script execute during package installation

```yaml
install-script: |
    echo "do some installation things"
    ls -al
```

## Users and groups

Package might expect the existence of some users or groups in the system to work properly

```yaml
users:
    - id: 100
      name: user-one
      about: An example user
      group: 100
      shell: /bin/false
      dir: /dev/null

groups:
    - id: 100
      name: a group

    - id: 120
      name: other group
```
