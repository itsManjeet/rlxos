kind: meson
sources:
- kind: tar
  url: gnome_downloads:phodav/3.0/phodav-3.0.tar.xz
  ref: 392ec2d06d50300dcff1ef269a2a985304e29bce3520002fca29f2edc1d138d1
build-depends:
- components/gtk-doc.bst
- freedesktop-sdk.bst:components/perl-xml-parser.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/avahi-gobject.bst
- components/glib.bst
- components/libsoup.bst
- freedesktop-sdk.bst:components/libgudev.bst
- freedesktop-sdk.bst:components/systemd.bst
- freedesktop-sdk.bst:bootstrap-import.bst
