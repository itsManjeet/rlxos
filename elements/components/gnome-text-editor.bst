kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-text-editor/43/gnome-text-editor-43.2.tar.xz
  ref: 33045c7a123faa27dee7eb9ba9a6f26f1b1718c5a0e76337d079a0d4c900e146
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
