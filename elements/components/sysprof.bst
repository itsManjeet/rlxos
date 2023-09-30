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
- components/libpanel.bst
- components/gtk.bst
- components/libadwaita.bst
- components/libdex.bst
- components/json-glib.bst
- freedesktop-sdk.bst:components/libunwind.bst
- freedesktop-sdk.bst:components/polkit.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dgtk=true
    -Dsysprofd=bundled
    -Dlibsysprof=true
    -Dtools=true
    -Dtests=true
    -Dexamples=false

public:
  bst:
    overlap-whitelist:
    - '%{includedir}/sysprof-6/*.h'
    - '%{libdir}/libsysprof-capture-6.a'
    - '%{libdir}/pkgconfig/sysprof-capture-4.pc'
    split-rules:
      sysprof-agent:
      - '%{bindir}/sysprof-agent'
