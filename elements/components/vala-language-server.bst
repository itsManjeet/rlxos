kind: meson

variables:
  meson-local: >-
    -Dman_pages=disabled

depends:
- components/libgee.bst
- components/vala.bst
- components/jsonrpc-glib.bst
- components/vala.bst

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst


sources:
- kind: git_tag
  url: github:vala-lang/vala-language-server
  track: master
  ref: 0.48.7-7-g3b5fe941bea6ecd5c8fcb84930c40b8582eea165
