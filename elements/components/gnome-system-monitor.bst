kind: meson
sources:
- kind: tar
  url: gnome_downloads:gnome-system-monitor/42/gnome-system-monitor-42.0.tar.xz
  ref: 13239d22032201a22bd29833c575b684816700d2de168a1530223577c5c075dc
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