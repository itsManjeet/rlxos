kind: autotools
sources:
- kind: tar
  url: freedesktop_software:libqmi/libqmi-1.30.8.tar.xz
  ref: 862482ce9e3ad0bd65d264334ee311cdb94b9df2863b5b7136309b41b8ac1990
build-depends:
- components/gtk-doc.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- components/glib.bst
- freedesktop-sdk.bst:components/libgudev.bst
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  conf-local: >-
    --enable-more-warnings=no
