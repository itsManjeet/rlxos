kind: meson

(@): elements/components/sysprof.inc

build-depends:
- freedesktop-sdk.bst:components/desktop-file-utils.bst
- freedesktop-sdk.bst:components/itstool.bst
- freedesktop-sdk.bst:components/systemd.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

runtime-depends:
- components/adwaita-icon-theme.bst

depends:
- components/gtk.bst
- components/libadwaita.bst
- components/json-glib.bst
- freedesktop-sdk.bst:components/libunwind.bst
- freedesktop-sdk.bst:components/polkit.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dagent=true

public:
  bst:
    # This might overlap with sysprof-minimal as due to some pkgcofnig/meson
    # quirkyness sysprof-capture ends up in Requires.private and now
    # is a runtime dependency of glib so other modules can find the .pc file
    # even though its a statically build dependency
    # see: sdk/glib.bst
    overlap-whitelist:
    - '%{includedir}/sysprof-4/*.h'
    - '%{libdir}/libsysprof-capture-4.a'
    - '%{libdir}/pkgconfig/sysprof-capture-4.pc'
    split-rules:
      sysprof-agent:
      - '%{bindir}/sysprof-agent'
      - '%{libdir}/libsysprof-memory-4.so'
      - '%{libdir}/libsysprof-speedtrack-4.so'
