kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-shell/43/gnome-shell-43.2.tar.xz
  ref: e76fd4be9342410ee9fbdcdd6b2d81c6ff060e7c8cc5a0f1cae6a7aba25d1860
build-depends:
- components/sassc.bst
- freedesktop-sdk.bst:components/asciidoc.bst
- freedesktop-sdk.bst:components/docbook-xsl.bst
- freedesktop-sdk.bst:components/perl.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

runtime-depends:
- components/libgnomekbd.bst
- components/libgweather.bst
- components/geoclue.bst

depends:
- components/networkmanager.bst
- components/accountsservice.bst
- components/dconf.bst
- components/evolution-data-server.bst
- components/gnome-autoar.bst
- components/startup-notification.bst
- components/upower.bst
- components/gdm.bst
- components/gnome-bluetooth.bst
- components/gnome-desktop.bst
- components/gnome-settings-daemon.bst
- components/mutter.bst
- components/adwaita-icon-theme.bst
- components/gcr.bst
- components/gjs.bst
- components/glib.bst
- components/gobject-introspection.bst
- components/gst-plugins-base.bst
- components/gtk.bst
- components/libsoup.bst
- freedesktop-sdk.bst:components/gstreamer.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dextensions_app=false
    -Dextensions-tool:bash_completion=disabled
    -Dtests=false
