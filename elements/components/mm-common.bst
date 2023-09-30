kind: meson
sources:
- kind: tar
  url: gnome_downloads:mm-common/1.0/mm-common-1.0.5.tar.xz
  ref: 705c6d29f4116a29bde4e36cfc1b046c92b6ef8c6dae4eaec85018747e6da5aa
- kind: local
  path: files/mm-common/libstdc++.tag
  directory: doctags/
build-depends:
- freedesktop-sdk.bst:components/python3.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  meson-local: >-
    -Duse-network=false
