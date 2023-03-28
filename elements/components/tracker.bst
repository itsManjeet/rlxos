kind: meson

sources:
- kind: tar
  url: gnome_downloads:tracker/3.4/tracker-3.4.2.tar.xz
  ref: 4e6df142a4f704878fca98ebb5a224750e5ea546aa2aaabaa726a73540bd1731
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
