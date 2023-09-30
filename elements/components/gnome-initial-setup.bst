kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-initial-setup/45/gnome-initial-setup-45.0.tar.xz
  ref: b1afe764798f8948bedb95c7ab31bd78529ac5cb481c41f7a7777f264de54bd8
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
- components/glib.bst
- components/gtk.bst
- components/libadwaita.bst
- components/webkitgtk-6.0.bst
- freedesktop-sdk.bst:components/gstreamer.bst
- freedesktop-sdk.bst:components/pwquality.bst
- freedesktop-sdk.bst:components/geoclue.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dparental_controls=enabled
