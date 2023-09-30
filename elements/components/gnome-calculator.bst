kind: meson
sources:
- kind: tar
  url: gnome_downloads:gnome-calculator/45/gnome-calculator-45.0.2.tar.xz
  ref: 7dcbf32384897171cbe5483ec664d994e5e755e912ae1df911624f03c90867c2
build-depends:
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
