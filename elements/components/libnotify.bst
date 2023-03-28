kind: meson

sources:
- kind: tar
  url: gnome_downloads:libnotify/0.8/libnotify-0.8.1.tar.xz
  ref: d033e6d4d6ccbf46a436c31628a4b661b36dca1f5d4174fe0173e274f4e62557
build-depends:
- components/gobject-introspection.bst
- components/gtk-doc.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/glib.bst
- components/gtk+-3.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Ddocbook_docs=disabled
    -Dman=false

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libnotify.so'
