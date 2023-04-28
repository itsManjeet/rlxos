kind: meson
sources:
- kind: tar
  url: gnome_downloads:gnome-calculator/44/gnome-calculator-44.0.tar.xz
  ref: 14e763329f88309a7e152780d57361b543100e323906b34e0655fdc315b71043
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
