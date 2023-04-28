kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-initial-setup/44/gnome-initial-setup-44.0.tar.xz
  ref: 593cfc6dc8f82a98671b94c035b97dbe88ef56e708780b2ad1d2324e4d04bbff
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
- components/webkitgtk-6.0.bst
- freedesktop-sdk.bst:components/gstreamer.bst
- freedesktop-sdk.bst:components/pwquality.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dparental_controls=enabled
