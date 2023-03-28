kind: autotools
sources:
- kind: tar
  url: https://github.com/intel/thermal_daemon/archive/v2.5.1/thermal_daemon-2.5.1.tar.gz

  ref: 75c165df45b3d09c904d314c8c19789158e9538f46e3d2b606457dc631eb3af5
depends:
- components/glib.bst
- components/upower.bst
- components/dbus-glib.bst
- freedesktop-sdk.bst:components/systemd.bst
- freedesktop-sdk.bst:components/libxml2.bst
- freedesktop-sdk.bst:components/libevdev.bst

runtime-depends:
- components/power-profiles-daemon.bst

build-depends:
- components/gtk-doc.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

variables:
  conf-local: >-
    --with-dbus-sys-dir=%{datadir}/dbus-1/system.d/
