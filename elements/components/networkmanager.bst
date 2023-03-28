kind: meson
sources:
- kind: tar
  url: gnome_downloads:NetworkManager/1.40/NetworkManager-1.40.10.tar.xz
  ref: fa251455df3c38e2bf1e1ff806b4bc4346938dd135a3568bd250e92caa85eaf7
build-depends:
- components/intltool.bst
- components/gobject-introspection.bst
- components/gtk-doc.bst
- components/vala.bst
- freedesktop-sdk.bst:components/perl-xml-parser.bst
- freedesktop-sdk.bst:components/systemd.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/modemmanager.bst
- components/mobile-broadband-provider-info.bst
- components/ppp.bst
- components/glib.bst
- components/pygobject.bst
- freedesktop-sdk.bst:components/curl.bst
- freedesktop-sdk.bst:components/dbus.bst
- freedesktop-sdk.bst:components/gnutls.bst
- freedesktop-sdk.bst:components/iptables.bst
- freedesktop-sdk.bst:components/libgudev.bst
- freedesktop-sdk.bst:components/libndp.bst
- freedesktop-sdk.bst:components/libpsl.bst
- freedesktop-sdk.bst:components/nss.bst
- freedesktop-sdk.bst:components/polkit.bst
- freedesktop-sdk.bst:components/systemd-libs.bst
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  meson-local: >-
    -Dmore_asserts=no
    -Dcrypto=gnutls
    -Dintrospection=true
    -Dvapi=true
    -Ddocs=true
    -Dtests=no
    -Dlibaudit=no
    -Dnmtui=false
    -Dselinux=false
    -Dqt=false
    -Dovs=false
