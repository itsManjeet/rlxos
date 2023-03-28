kind: meson
sources:
- kind: tar
  url: gnome_downloads:grilo-plugins/0.3/grilo-plugins-0.3.15.tar.xz
  ref: 8518c3d954f93095d955624a044ce16a7345532f811d299dbfa1e114cfebab33
build-depends:
- freedesktop-sdk.bst:components/itstool.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/gmime.bst
- components/gnome-online-accounts.bst
- components/gom.bst
- components/grilo.bst
- components/libgdata.bst
- components/libmediaart.bst
- components/totem-pl-parser.bst
- components/json-glib.bst
- components/libsoup-2.4.bst
- components/tracker.bst
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  meson-local: >-
    -Denable-lua-factory=no
    -Denable-tracker=no
    -Denable-tracker3=yes
