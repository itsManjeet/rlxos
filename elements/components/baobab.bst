kind: meson
sources:
- kind: tar
  url: gnome_downloads:baobab/45/baobab-45.0.tar.xz
  ref: a7d2cf308a6c839ee0b0bf074f8f5fd60d62ae2f064a94b3c610d6560b758e86
build-depends:
- components/vala.bst
- freedesktop-sdk.bst:components/desktop-file-utils.bst
- freedesktop-sdk.bst:components/itstool.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/adwaita-icon-theme.bst
- components/glib.bst
- components/gtk.bst
- components/libadwaita.bst
- components/librsvg.bst
- freedesktop-sdk.bst:bootstrap-import.bst
