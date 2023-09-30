kind: meson

sources:
- kind: tar
  url: cairo:snapshots/cairo-1.17.8.tar.xz
  ref: 5b10c8892d1b58d70d3f0ba5b47863a061262fa56b9dc7944161f8c8b783bc64

build-depends:
- sdk/gtk-doc.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- freedesktop-sdk.bst:components/fontconfig.bst
- freedesktop-sdk.bst:components/freetype.bst
- freedesktop-sdk.bst:components/pixman.bst
- freedesktop-sdk.bst:components/xorg-lib-x11.bst
- freedesktop-sdk.bst:components/xorg-lib-xext.bst
- freedesktop-sdk.bst:bootstrap-import.bst
public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{bindir}/cairo-sphinx'
        - '%{bindir}/cairo-trace'
        - '%{libdir}/libcairo-script-interpreter.so'
        - '%{libdir}/libcairo-gobject.so'
        - '%{libdir}/libcairo.so'
        - '%{libdir}/cairo/libcairo-trace.so'
variables:
  meson-local: >-
    -Dspectre=disabled
    -Dsymbol-lookup=disabled
    -Dtests=disabled