kind: meson

sources:
- kind: tar
  url: gnome_downloads:mutter/43/mutter-43.2.tar.xz
  ref: fd2eb707adc333cc277af8685e5cf39135e1c4d798a1f9d05e88e453dc3ebb84
build-depends:
# Need the whole thing over just the capture for the dbus interface.
# /usr/share/dbus-1/interfaces/org.gnome.Sysprof3.Profiler.xml
- components/sysprof-app.bst
- components/gtk-doc.bst
- freedesktop-sdk.bst:components/xorg-lib-xcvt.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

runtime-depends:
  # xwayland crashes when gnome-control-center not present
- components/gnome-control-center.bst

depends:
- components/startup-notification.bst
- components/libinput.bst
- components/upower.bst
- components/gnome-desktop.bst
- components/gnome-settings-daemon.bst
- components/gdk-pixbuf.bst
- components/glib.bst
- components/gobject-introspection.bst
- components/graphene.bst
- components/gsettings-desktop-schemas.bst
- components/gtk+-3.bst
- components/json-glib.bst
- components/pango.bst
- components/pipewire.bst
- freedesktop-sdk.bst:components/dummy-gbm.bst
- freedesktop-sdk.bst:components/libgudev.bst
- freedesktop-sdk.bst:components/wayland.bst
- freedesktop-sdk.bst:components/xorg-lib-ice.bst
- freedesktop-sdk.bst:components/xorg-lib-sm.bst
- freedesktop-sdk.bst:components/xorg-lib-xcursor.bst
- freedesktop-sdk.bst:components/xorg-lib-xtst.bst
- freedesktop-sdk.bst:components/xwayland.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dxwayland_initfd=enabled
    -Dprofiler=true
    -Dtests=false
