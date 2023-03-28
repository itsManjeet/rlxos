kind: meson

sources:
- kind: tar
  url: gnome_downloads:dconf/0.40/dconf-0.40.0.tar.xz
  ref: cf7f22a4c9200421d8d3325c5c1b8b93a36843650c9f95d6451e20f0bcb24533
build-depends:
- components/vala.bst
- freedesktop-sdk.bst:components/dbus.bst
- freedesktop-sdk.bst:components/docbook-xsl.bst
- freedesktop-sdk.bst:components/libxslt.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/glib.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dbash_completion=false

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libdconf.so'
