kind: meson
sources:
- kind: tar
  url: pagure_releases:libosinfo/osinfo-db-tools-1.10.0.tar.xz
  ref: 802cdd53b416706ea5844f046ddcfb658c1b4906b9f940c79ac7abc50981ca68
build-depends:
- freedesktop-sdk.bst:components/libxslt.bst
- freedesktop-sdk.bst:components/perl-xml-parser.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/glib.bst
- components/json-glib.bst
- components/libsoup-2.4.bst
- freedesktop-sdk.bst:components/libarchive.bst
- freedesktop-sdk.bst:components/libxml2.bst
- freedesktop-sdk.bst:bootstrap-import.bst
