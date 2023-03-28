kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-software/43/gnome-software-43.3.tar.xz
  ref: 93ee80747978ad2cc02e5ae73d0a3d3ec82eea134fc779e2aa916901bbb58090
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
    -Dsoup2=true
    -Dhardcoded_curated=true
    -Ddefault_featured_apps=true
