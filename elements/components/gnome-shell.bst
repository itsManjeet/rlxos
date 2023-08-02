kind: meson

sources:
- kind: git_tag
  url: gnome:gnome-shell
  track: 44.3
  submodules:
    subprojects/gvc:
      checkout: true
      url: gnome:libgnome-volume-control.git
      
  ref: 44.3-0-g60ec50efa693735cb959a3378516a82d2e9df009
- kind: patch
  path: patches/gnome-shell/0001-rlxos-specific-modifications.patch

build-depends:
- components/sassc.bst
- freedesktop-sdk.bst:components/asciidoc.bst
- freedesktop-sdk.bst:components/docbook-xsl.bst
- freedesktop-sdk.bst:components/patch.bst
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
