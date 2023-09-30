kind: meson

sources:
- kind: tar
  url: gnome_downloads:libadwaita/1.4/libadwaita-1.4.0.tar.xz
  ref: e51a098a54d43568218fc48fcf52e80e36f469b3ce912d8ce9c308a37e9f47c2

build-depends:
- components/gi-docgen.bst
- components/sassc.bst
- components/gobject-introspection.bst
- components/sysprof-minimal.bst
- components/vala.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/gtk.bst
- freedesktop-sdk.bst:components/appstream.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dprofiling=true
    -Dgtk_doc=true

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{bindir}/adwaita-1-demo'
        - '%{datadir}/applications/org.gnome.Adwaita1.Demo.desktop'
        - '%{datadir}/metainfo/org.gnome.Adwaita1.Demo.metainfo.xml'
        - '%{libdir}/libadwaita-1.so'
