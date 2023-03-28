kind: autotools

sources:
- kind: tar
  url: gnome_downloads:NetworkManager-fortisslvpn/1.3/NetworkManager-fortisslvpn-1.3.90.tar.xz

  ref: 884a7432bb38ae9c942e094f23d0a3feb504432153c3d2869ab71a4dd244d0fb
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
- components/intltool.bst

depends:
- components/gtk+-3.bst
- components/libnma.bst
- components/networkmanager.bst
- components/openfortivpn.bst

variables:
  conf-local: >-
    --without-libnm-glib
