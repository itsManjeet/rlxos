kind: meson
sources:
- kind: tar
  url: gnome_downloads:cantarell-fonts/0.303/cantarell-fonts-0.303.1.tar.xz
  ref: f9463a0659c63e57e381fdd753cf1929225395c5b49135989424761830530411
build-depends:
- components/appstream-glib.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  meson-local: >-
    -Duseprebuilt=true
