kind: meson
sources:
- kind: tar
  url: gnome_downloads:gtk-doc/1.33/gtk-doc-1.33.2.tar.xz
  ref: cc1b709a20eb030a278a1f9842a362e00402b7f834ae1df4c1998a723152bf43
build-depends:
- freedesktop-sdk.bst:components/itstool.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- freedesktop-sdk.bst:components/docbook-xsl.bst
- freedesktop-sdk.bst:components/libxslt.bst
- freedesktop-sdk.bst:components/pkg-config.bst
- freedesktop-sdk.bst:components/python3-pygments.bst
- freedesktop-sdk.bst:components/python3.bst
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  meson-local: >-
    -Dtests=false
