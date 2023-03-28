kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-control-center/43/gnome-control-center-43.2.tar.xz
  ref: d7f256aba80a92c727b329fd01c8602da4b78f0fddaec93fcd91096964700563
build-depends:
- components/gtk-doc.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- components/cheese.bst

runtime-depends:
- components/libgnomekbd.bst
- components/power-profiles-daemon.bst

depends:
- components/modemmanager.bst
- components/networkmanager.bst
- components/accountsservice.bst
- components/colord-gtk.bst
- components/colord.bst
- components/gnome-online-accounts.bst
- components/gsound.bst
- components/ibus-daemon.bst
- components/libgtop.bst
- components/libnma.bst
- components/malcontent.bst
- components/samba.bst
- components/system-config-printer.bst
- components/udisks2.bst
- components/upower.bst
- components/gnome-bluetooth.bst
- components/gnome-color-manager.bst
- components/gnome-desktop.bst
- components/gnome-settings-daemon.bst
- components/adwaita-icon-theme.bst
- components/gdk-pixbuf.bst
- components/glib.bst
- components/gsettings-desktop-schemas.bst
- components/gtk.bst
- components/libadwaita.bst
- components/branding.bst
- freedesktop-sdk.bst:components/gstreamer.bst
- freedesktop-sdk.bst:components/libwacom.bst
- freedesktop-sdk.bst:components/pwquality.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Ddocumentation=true
    -Dmalcontent=true
    -Ddistributor_logo=%{datadir}/icons/logo.svg
    -Ddark_mode_distributor_logo=%{datadir}/icons/logo_alt.svg
