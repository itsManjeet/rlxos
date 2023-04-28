kind: meson

sources:
- kind: tar
  url: gnome_downloads:tracker/3.5/tracker-3.5.1.tar.xz
  ref: f972d50ac7bafdccf113b1eb99dcae35404685a99e55bfef16f3ac83b4de974d
build-depends:
- components/gobject-introspection.bst
- components/vala.bst
- components/pygobject.bst
- freedesktop-sdk.bst:components/asciidoc.bst
- freedesktop-sdk.bst:components/systemd.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/glib.bst
- components/json-glib.bst
- components/libsoup.bst
- freedesktop-sdk.bst:components/dbus.bst
- freedesktop-sdk.bst:components/icu.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Ddocs=false
    -Dunicode_support=icu
    -Dstemmer=disabled
