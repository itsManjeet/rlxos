kind: meson

sources:
- kind: tar
  url: gnome_downloads:folks/0.15/folks-0.15.5.tar.xz
  ref: 0fff8a896330cd82aee4598324f7e541c884d0337536212723b4beb38c759086
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
