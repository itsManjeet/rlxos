kind: autotools
sources:
- kind: tar
  url: gnome_downloads:libgee/0.20/libgee-0.20.6.tar.xz
  ref: 1bf834f5e10d60cc6124d74ed3c1dd38da646787fbf7872220b8b4068e476d4d
build-depends:
- components/gobject-introspection.bst
- components/vala.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- components/glib.bst
- freedesktop-sdk.bst:bootstrap-import.bst
public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libgee-0.8.so'
