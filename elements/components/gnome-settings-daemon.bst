kind: meson
sources:
- kind: tar
  url: gnome_downloads:gnome-settings-daemon/44/gnome-settings-daemon-44.1.tar.xz
  ref: 12653b72d81f151300a47d700ac9410ac1bcce38e83f1bdd19cded2932943989
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
- components/geoclue.bst
- components/glib.bst
- components/gsettings-desktop-schemas.bst
- components/gtk+-3.bst
- components/libnotify.bst
- freedesktop-sdk.bst:components/alsa-lib.bst
- freedesktop-sdk.bst:components/libgudev.bst
- freedesktop-sdk.bst:components/libwacom.bst
- freedesktop-sdk.bst:components/xorg-lib-xtst.bst
- freedesktop-sdk.bst:bootstrap-import.bst
