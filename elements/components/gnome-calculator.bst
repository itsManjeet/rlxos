kind: meson
sources:
- kind: tar
  url: gnome_downloads:gnome-calculator/43/gnome-calculator-43.0.1.tar.xz
  ref: 02c12ded3cf5053d17537d95ec69587f4b919899d7726eceecdb4b47ffb1c90f
build-depends:
- components/appstream-glib.bst
- components/vala.bst
- freedesktop-sdk.bst:components/itstool.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/mpc.bst
- components/adwaita-icon-theme.bst
- components/glib.bst
- components/gtk.bst
- components/gtksourceview.bst
- components/libadwaita.bst
- components/libgee.bst
- components/libsoup.bst
- freedesktop-sdk.bst:bootstrap-import.bst
