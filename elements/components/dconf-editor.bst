kind: meson
sources:
- kind: tar
  url: gnome_downloads:dconf-editor/43/dconf-editor-43.0.tar.xz
  ref: 935a3c2dd76cc2a93cd5aee9a54d3947fb111eb396f4b63dc5f0ba8f8d099136
build-depends:
- components/appstream-glib.bst
- components/vala.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/dconf.bst
- components/glib.bst
- components/gtk+-3.bst
- components/libhandy.bst
- freedesktop-sdk.bst:bootstrap-import.bst
