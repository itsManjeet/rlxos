kind: meson
sources:
- kind: tar
  url: gnome_downloads:gdm/44/gdm-44.1.tar.xz
  ref: 68266b3abe7d28fc469d0067aac9c5dabb0ca7952cc1f7c238a04951f3dc5b0d
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

    # TODO: Better way??
    # Enable wayland support with nvidia graphics card
    - rm %{install-root}%{indep-libdir}/udev/rules.d/61-gdm.rules

    - mkdir -p %{install-root}%{pamdir}
    - |
      # Our configuration is similar to redhat but without selinux
      for conffile in `find gdm-config/ -name "*.pam"`; do
        install -m 644 $conffile %{install-root}%{pamdir}/$(basename ${conffile%.pam})
      done
