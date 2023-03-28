kind: autotools
sources:
- kind: tar
  url: freedesktop_software:ModemManager/ModemManager-1.18.12.tar.xz
  ref: b464e4925d955a6ca86dd08616e763b26ae46d7fd37dbe281678e34065b1e430
build-depends:
- components/gtk-doc.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- components/libmbim.bst
- components/libqmi.bst
- components/glib.bst
- freedesktop-sdk.bst:components/libgudev.bst
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  conf-local: >-
    --with-udev-base-dir=/usr/lib/udev
    --disable-more-warnings
