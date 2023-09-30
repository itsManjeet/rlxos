kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-text-editor/45/gnome-text-editor-45.0.tar.xz
  ref: 47b3fbe4900eb204413d9af3ae8e0ecd06728d2ac15d02b1a050d02d47226bc1
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
