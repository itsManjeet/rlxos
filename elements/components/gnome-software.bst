kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-software/44/gnome-software-44.1.tar.xz
  ref: 9dc6551512cf0a26d03e0d79f494870a6916d43c14d82199c43a11d9cc0ad5aa
build-depends:
- components/gtk-doc.bst
- components/sysprof-minimal.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/appstream.bst
- components/eos-updater.bst
- components/flatpak.bst
- components/fwupd.bst
- components/glib-testing.bst
- components/gnome-online-accounts.bst
- components/gspell.bst
- components/liboauth.bst
- components/malcontent.bst
- components/xmlb.bst
- components/gnome-desktop.bst
- components/adwaita-icon-theme.bst
- components/glib.bst
- components/gsettings-desktop-schemas.bst
- components/gtk.bst
- components/libadwaita.bst
- components/libsecret.bst
- components/libsoup-2.4.bst
- freedesktop-sdk.bst:components/libgudev.bst
- freedesktop-sdk.bst:components/polkit.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dfwupd=true
    -Dpolkit=true
    -Dflatpak=true
    -Deos_updater=true
    -Dpackagekit=false
