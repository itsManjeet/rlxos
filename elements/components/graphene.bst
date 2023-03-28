kind: meson

sources:
- kind: tar
  url: gnome_downloads:graphene/1.10/graphene-1.10.8.tar.xz
  ref: a37bb0e78a419dcbeaa9c7027bcff52f5ec2367c25ec859da31dfde2928f279a
build-depends:
- components/gobject-introspection.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/glib.bst
- freedesktop-sdk.bst:bootstrap-import.bst

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libgraphene-1.0.so'
