kind: meson
sources:
- kind: tar
  url: pagure_releases:libosinfo/libosinfo-1.10.0.tar.xz
  ref: a252e00fc580deb21da0da8c0aa03b8c31e8440b8448c8b98143fab477d32305
- kind: local
  path: files/libosinfo/pci.ids
- kind: local
  path: files/libosinfo/usb.ids
build-depends:
- components/gobject-introspection.bst
- components/gtk-doc.bst
- components/vala.bst
- freedesktop-sdk.bst:components/perl-xml-parser.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/osinfo-db-tools.bst
- components/glib.bst
- components/libsoup.bst
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  meson-local: >-
    -Denable-tests=false
config:
  install-commands:
    (>):
    - install -Dm644 -t '%{install-root}%{datadir}/libosinfo' pci.ids usb.ids
