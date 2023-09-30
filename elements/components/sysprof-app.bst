kind: filter

build-depends:
- components/sysprof.bst

runtime-depends:
- components/libpanel.bst
- components/adwaita-icon-theme.bst
- components/glib.bst
- components/gtk.bst
- components/json-glib.bst
- components/libadwaita.bst
- components/libdex.bst
- freedesktop-sdk.bst:components/libunwind.bst
- freedesktop-sdk.bst:components/polkit.bst
- freedesktop-sdk.bst:bootstrap-import.bst

config:
  exclude:
  - sysprof-agent

public:
  bst:
    overlap-whitelist:
    - '%{includedir}/sysprof-6/*.h'
    - '%{libdir}/libsysprof-capture-4.a'
    - '%{libdir}/pkgconfig/sysprof-capture-4.pc'
