kind: meson
sources:
- kind: tar
  url: freedesktop_software:colord/releases/colord-1.4.6.tar.xz
  ref: 7407631a27bfe5d1b672e7ae42777001c105d860b7b7392283c8c6300de88e6f
build-depends:
- components/gobject-introspection.bst
- components/gtk-doc.bst
- components/vala.bst
- freedesktop-sdk.bst:components/systemd.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/libgusb.bst
- components/glib.bst
- freedesktop-sdk.bst:components/lcms.bst
- freedesktop-sdk.bst:components/libgudev.bst
- freedesktop-sdk.bst:components/polkit.bst
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  meson-local: >-
    -Dargyllcms_sensor=false
    -Dbash_completion=false
    -Dlibcolordcompat=false
    -Dman=false
    -Dvapi=true
