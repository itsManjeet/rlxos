kind: make
description: Linux kernel configured for use in virtual machines.

depends:
- freedesktop-sdk.bst:components/kmod.bst

build-depends:
- freedesktop-sdk.bst:bootstrap-import.bst
- freedesktop-sdk.bst:components/bison.bst
- freedesktop-sdk.bst:components/flex.bst
- freedesktop-sdk.bst:components/bc.bst
- freedesktop-sdk.bst:components/gzip.bst
- freedesktop-sdk.bst:components/rsync.bst
- freedesktop-sdk.bst:components/cpio.bst
- freedesktop-sdk.bst:components/zstd.bst

variables:
  bootdir: /boot
  kernel_arch: '%{arch}'
  src-arch: '%{kernel_arch}'
  image-name: '$(make -s image_name)'
  (?):
  - arch == "x86_64":
      src-arch: x86
  - arch == "i686":
      src-arch: x86
      kernel_arch: i386



environment:
  ARCH: '%{kernel_arch}'
  MAXJOBS: "%{max-jobs}"

environment-nocache:
- MAXJOBS

config:
  configure-commands:
  - |
    # Generate the default kernel config for the target architecture
    cp config .config
    make olddefconfig

  install-commands:
  - |
    install -Dm644 "%{image-name}" '%{install-root}%{bootdir}/vmlinuz'
    install -Dm644 System.map '%{install-root}%{bootdir}/System.map'
    install -Dm644 .config '%{install-root}%{bootdir}/config'
    make -j1 INSTALL_MOD_PATH='%{install-root}%{prefix}' modules_install

  - |
    release=$(make -s kernelrelease)
    find "%{install-root}%{indep-libdir}/modules/${release}" -type f -name '*.ko' | xargs -P $MAXJOBS -n 2 -r xz;

  - |
    release=$(make -s kernelrelease)
    targetdir="%{install-root}%{prefix}/src/linux"

    rm "%{install-root}%{indep-libdir}/modules/${release}"/{source,build}

    to_copy=(
      Makefile
      Module.symvers
      .config
      "arch/%{src-arch}/include"
      "arch/%{src-arch}/Makefile"
      scripts
      include
      tools/objtool/objtool
    )
    for file in "${to_copy[@]}"
    do
      targetfile="${targetdir}/${file}"
      dir="$(dirname "${targetfile}")"
      [ -d "${dir}" ] || install -d "${dir}"
      cp -aT "${file}" "${targetfile}"
    done

    ln -sr "${targetdir}" "%{install-root}%{indep-libdir}/modules/${release}/source"
    ln -sr "${targetdir}" "%{install-root}%{indep-libdir}/modules/${release}/build"

public:
  bst:
    integration-commands:
    - |
      cd '%{indep-libdir}/modules'
      for version in *; do
        depmod -b '%{prefix}' -a "$version";
      done

    split-rules:
      devel:
        (>):
        - '%{bootdir}/System.map'

sources:
- kind: tar
  url: https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.0.7.tar.xz
  ref: 67dacc2b78605a56e997f4c08d009be87c98ec66f1870220226c8b3cc676590f
- kind: local
  path: files/linux/
