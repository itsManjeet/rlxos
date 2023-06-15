kind: meson

depends:
- components/json-glib.bst

build-depends:
- components/gobject-introspection.bst
- components/vala.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

sources:
- kind: git_tag
  url: gnome:jsonrpc-glib.git
  track: main
  ref: 3.44.0-1-g67d6b14d621b19f30d697c2e883db59aeb064f3e
