kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-initial-setup/43/gnome-initial-setup-43.2.tar.xz
  ref: 23d7963a54d49594504d0eacd85096cafb5f86f1e74a58e040675b6e798ae698
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/networkmanager.bst
- components/accountsservice.bst
- components/geocode-glib.bst
- components/gnome-online-accounts.bst
- components/ibus-daemon.bst
- components/libgweather.bst
- components/libnma.bst
- components/librest.bst
- components/malcontent.bst
- components/upower.bst
- components/gdm.bst
- components/gnome-desktop.bst
- components/gnome-keyring.bst
- components/adwaita-icon-theme.bst
- components/geoclue.bst
- components/glib.bst
- components/gtk.bst
- components/libadwaita.bst
- components/webkit2gtk-5.0.bst
- freedesktop-sdk.bst:components/gstreamer.bst
- freedesktop-sdk.bst:components/pwquality.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dparental_controls=enabled
