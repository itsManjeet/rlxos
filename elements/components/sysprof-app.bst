kind: filter

build-depends:
- components/sysprof.bst

runtime-depends:
- components/adwaita-icon-theme.bst
- components/glib.bst
- components/gtk.bst
- components/libadwaita.bst
- freedesktop-sdk.bst:components/libunwind.bst
- freedesktop-sdk.bst:components/polkit.bst
- freedesktop-sdk.bst:bootstrap-import.bst

config:
  exclude:
  - sysprof-agent

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
