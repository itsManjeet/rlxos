kind: meson

sources:
- kind: tar
  url: github_files:aruiz/webp-pixbuf-loader/archive/refs/tags/0.0.6.tar.gz

  ref: 451cb6924a9aa6afaa21d5b63b402dcfcfe952a1873e078b17078c4a1964a693
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/gdk-pixbuf.bst
- freedesktop-sdk.bst:components/libwebp.bst
- freedesktop-sdk.bst:bootstrap-import.bst
