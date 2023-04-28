kind: meson
sources:
- kind: tar
  url: gnome_downloads:gnome-system-monitor/44/gnome-system-monitor-44.0.tar.xz
  ref: c2bab7eddba92827c4c8de44293e7e3c84c9e5076f31985887ff8969cec45e6e
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
