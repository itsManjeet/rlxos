kind: meson
sources:
- kind: tar
  url: gnome_downloads:gdm/43/gdm-43.0.tar.xz
  ref: 94d70d6ed7df59fa7fde4fd02fed1168593a8adce10fcee113c148d52b392294
- kind: local
  path: files/gdm
  directory: gdm-config
build-depends:
- components/yelp-tools.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/accountsservice.bst
- components/dconf.bst
- components/libcanberra.bst
- components/plymouth.bst
- components/upower.bst
- components/glib.bst
- components/gtk+-3.bst
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  sysusersdir: '%{prefix}/lib/sysusers.d'
  pamdir: '%{sysconfdir}/pam.d'
  meson-local: >-
    -Ddefault-pam-config=none
    -Dlibaudit=disabled
    -Dpam-prefix=%{sysconfdir}
    -Dplymouth=enabled
    -Drun-dir=/run/gdm
    -Dselinux=disabled
    -Dxdmcp=disabled

config:
  install-commands:
    (>):
    - mkdir -p %{install-root}%{sysusersdir}
    - install -m 644 gdm-config/gdm-sysusers.conf %{install-root}%{sysusersdir}/gdm.conf

    - mkdir -p %{install-root}%{pamdir}
    - |
      # Our configuration is similar to redhat but without selinux
      for conffile in `find gdm-config/ -name "*.pam"`; do
        install -m 644 $conffile %{install-root}%{pamdir}/$(basename ${conffile%.pam})
      done
