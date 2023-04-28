kind: meson

sources:
- kind: tar
  url: gnome_downloads:folks/0.15/folks-0.15.6.tar.xz
  ref: c866630c553f29ce9be1c7a60267cb4080a6bccf4b8d551dc4c7e6234d840248
build-depends:
- components/gobject-introspection.bst
- components/vala.bst
- freedesktop-sdk.bst:components/python3-dbusmock.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/evolution-data-server.bst
- components/libgee.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Deds_backend=true
    -Dtelepathy_backend=false
