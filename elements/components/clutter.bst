kind: autotools
sources:
- kind: tar
  url: gnome_downloads:clutter/1.26/clutter-1.26.4.tar.xz
  ref: 8b48fac159843f556d0a6be3dbfc6b083fc6d9c58a20a49a6b4919ab4263c4e6
build-depends:
- components/gobject-introspection.bst
- components/gtk-doc.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- components/cogl.bst
- components/at-spi2-core.bst
- components/gdk-pixbuf.bst
- components/glib.bst
- components/gtk+-3.bst
- components/json-glib.bst
- freedesktop-sdk.bst:components/libxkbcommon.bst
- freedesktop-sdk.bst:components/wayland.bst
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  conf-local: >-
    --enable-installed-tests
    --disable-maintainer-flags
    --enable-egl-backend
    --enable-evdev-input
    --enable-wayland-backend
    --enable-wayland-compositor
    --enable-gdk-backend
public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libclutter-1.0.so'
        - '%{libdir}/libclutter-glx-1.0.so'
