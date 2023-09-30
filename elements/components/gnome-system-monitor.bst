kind: meson
sources:
- kind: tar
  url: gnome_downloads:gnome-system-monitor/45/gnome-system-monitor-45.0.2.tar.xz
  ref: c5e272d90bf9986a3f8613d76e0d27fa42dfacee5c0192e73921bb94b1868a2e
build-depends:
- freedesktop-sdk.bst:components/itstool.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/gtkmm-3.bst
- components/libgtop.bst
- components/adwaita-icon-theme.bst
- components/glib.bst
- components/gtk+-3.bst
- components/libhandy.bst
- components/librsvg.bst
- freedesktop-sdk.bst:components/polkit.bst
- freedesktop-sdk.bst:bootstrap-import.bst
