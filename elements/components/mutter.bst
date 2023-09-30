kind: meson

variables:
  meson-local: >-
    -Dxwayland_initfd=enabled
    -Dprofiler=true

build-depends:
- components/xvfb.bst
- components/sysprof-app.bst
- components/gtk-doc.bst
- freedesktop-sdk.bst:components/xorg-lib-xcvt.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

runtime-depends:
- components/gnome-control-center.bst

depends:
- components/libei.bst
- components/startup-notification.bst
- components/upower.bst
- components/gnome-desktop.bst
- components/gnome-settings-daemon.bst
- components/gdk-pixbuf.bst
- components/glib.bst
- components/gobject-introspection.bst
- components/graphene.bst
- components/gsettings-desktop-schemas.bst
- components/gtk.bst
- components/json-glib.bst
- components/pango.bst
- freedesktop-sdk.bst:components/dummy-gbm.bst
- freedesktop-sdk.bst:components/libgudev.bst
- freedesktop-sdk.bst:components/wayland.bst
- freedesktop-sdk.bst:components/xorg-lib-ice.bst
- freedesktop-sdk.bst:components/xorg-lib-sm.bst
- freedesktop-sdk.bst:components/xorg-lib-xcursor.bst
- freedesktop-sdk.bst:components/xorg-lib-xtst.bst
- freedesktop-sdk.bst:components/libinput.bst
- freedesktop-sdk.bst:components/pipewire.bst
- freedesktop-sdk.bst:components/xwayland.bst
- freedesktop-sdk.bst:bootstrap-import.bst

sources:
- kind: tar
  url: gnome_downloads:mutter/45/mutter-45.0.tar.xz
  ref: 8fbc963019eda9ba52fca2f6c4c477efbc6e36eb4fa93f23174f02ff6b907715
