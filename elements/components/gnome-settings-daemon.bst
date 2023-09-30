kind: meson
sources:
- kind: tar
  url: gnome_downloads:gnome-settings-daemon/45/gnome-settings-daemon-45.0.tar.xz
  ref: bb4dc46950e2a90f38f23225848856d2a7b1b718c89d0285ce197b7016bb1dc8
build-depends:
- freedesktop-sdk.bst:components/perl.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/modemmanager.bst
- components/networkmanager.bst
- components/colord.bst
- components/cups-pk-helper.bst
- components/geocode-glib.bst
- components/ibus-daemon.bst
- components/libcanberra.bst
- components/libgweather.bst
- components/upower.bst
- components/gnome-desktop.bst
- components/gcr.bst
- components/glib.bst
- components/gsettings-desktop-schemas.bst
- components/gtk+-3.bst
- components/libnotify.bst
- freedesktop-sdk.bst:components/alsa-lib.bst
- freedesktop-sdk.bst:components/libgudev.bst
- freedesktop-sdk.bst:components/geoclue.bst
- freedesktop-sdk.bst:components/libwacom.bst
- freedesktop-sdk.bst:components/xorg-lib-xtst.bst
- freedesktop-sdk.bst:bootstrap-import.bst
