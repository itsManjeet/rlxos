kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-software/45/gnome-software-45.0.tar.xz
  ref: 61f42c2fd4d19b894a2484f691369032dc8b2a32a014ce6ca4d02c4fa4f75a14
build-depends:
- components/gtk-doc.bst
- components/sysprof-minimal.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/eos-updater.bst
- components/fwupd.bst
- components/glib-testing.bst
- components/gnome-online-accounts.bst
- components/gspell.bst
- components/liboauth.bst
- components/malcontent.bst
- components/gnome-desktop.bst
- components/adwaita-icon-theme.bst
- components/glib.bst
- components/gsettings-desktop-schemas.bst
- components/gtk.bst
- components/libadwaita.bst
- components/libsecret.bst
- components/libsoup-2.4.bst
- freedesktop-sdk.bst:components/appstream.bst
- freedesktop-sdk.bst:components/flatpak.bst
- freedesktop-sdk.bst:components/libgudev.bst
- freedesktop-sdk.bst:components/polkit.bst
- freedesktop-sdk.bst:bootstrap-import.bst
- freedesktop-sdk.bst:components/libxmlb.bst


variables:
  meson-local: >-
    -Dfwupd=true
    -Dpolkit=true
    -Dflatpak=true
    -Deos_updater=true
    -Dpackagekit=false
