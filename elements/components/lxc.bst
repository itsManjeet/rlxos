kind: meson

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- freedesktop-sdk.bst:components/systemd.bst

depends:
- freedesktop-sdk.bst:bootstrap-import.bst
- freedesktop-sdk.bst:components/systemd-libs.bst
- freedesktop-sdk.bst:components/libseccomp.bst
- freedesktop-sdk.bst:components/linux-pam-base.bst


variables:
  meson-local: >-
    -Ddistrosysconfdir=default
    -Dman=false

config:
  install-commands:
    (>):
    - |
      mkdir -p %{install-root}%{indep-libdir}/tmpfiles.d/
      echo "w /sys/fs/cgroup/memory/memory.use_hierarchy - - - - 1" > %{install-root}%{indep-libdir}/tmpfiles.d/lxc.conf
      install -d m755 %{install-root}%{localstatedir}/lib/lxc
      install -d m755 %{install-root}%{datadir}/lib/lxc/rootfs/dev
    - |
      unitdir="$(pkg-config --variable=systemdsystemunitdir systemd)"
      install -Dm644 -t %{install-root}${unitdir} lxc.service
      install -Dm644 -t %{install-root}${unitdir} lxc-auto.service


sources:
- kind: tar
  url: linuxcontainers:lxc/lxc-5.0.2.tar.gz
  ref: bea08d2e49efcee34fa58acd2bc95c0adc64d291c07f4cfaf4ac1d8ac5a36f45

- kind: local
  path: files/lxc