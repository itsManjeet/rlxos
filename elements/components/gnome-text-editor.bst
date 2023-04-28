kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-text-editor/44/gnome-text-editor-44.0.tar.xz
  ref: f67bc3780734ffa815fcc4c5daa7b555d24e459f81ea2b548e6a85c1612a31ca
build-depends:
- freedesktop-sdk.bst:components/desktop-file-utils.bst
- freedesktop-sdk.bst:components/itstool.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/editorconfig-core-c.bst
- components/adwaita-icon-theme.bst
- components/enchant-2.bst
- components/gtksourceview.bst
- components/libadwaita.bst
- freedesktop-sdk.bst:bootstrap-import.bst
