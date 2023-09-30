kind: meson
sources:
- kind: tar
  url: gnome_downloads:at-spi2-core/2.50/at-spi2-core-2.50.0.tar.xz
  ref: e9f5a8c8235c9dd963b2171de9120301129c677dde933955e1df618b949c4adc
build-depends:
- components/gi-docgen.bst
- components/gobject-introspection.bst
- components/gtk-doc.bst
- freedesktop-sdk.bst:components/libxml2.bst
- freedesktop-sdk.bst:components/python3-sphinx.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/glib.bst
- freedesktop-sdk.bst:components/dbus.bst
- freedesktop-sdk.bst:components/xorg-lib-xtst.bst
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  meson-local: >-
    -Ddocs=true
public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libatk-1.0.so'
        - '%{libdir}/libatk-bridge-2.0.so'
        - '%{libdir}/libatspi.so'
