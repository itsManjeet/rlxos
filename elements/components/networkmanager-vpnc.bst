kind: autotools

sources:
- kind: tar
  url: gnome_downloads:NetworkManager-vpnc/1.2/NetworkManager-vpnc-1.2.6.tar.xz

  ref: de4fd059c4c08365a40b32b6f6fad9674f556724b4bbeb1f9d4473ac19a745cb
variables:
  conf-local: >-
    --without-libnm-glib

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
- components/intltool.bst

depends:
- components/gtk+-3.bst
- components/libnma.bst
- components/networkmanager.bst

runtime-depends:
- components/vpnc.bst
