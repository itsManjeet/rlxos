kind: meson

sources:
- kind: tar
  url: gnome_downloads:libadwaita/1.2/libadwaita-1.2.1.tar.xz
  ref: 326f142a4f0f3de5a63f0d5e7a9de66ea85348a4726cbfd13930dcf666d22779
build-depends:
- components/gi-docgen.bst
- components/sassc.bst
- components/gobject-introspection.bst
- components/sysprof-minimal.bst
- components/vala.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/gtk.bst
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
