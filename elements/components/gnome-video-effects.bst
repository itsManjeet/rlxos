kind: meson
sources:
- kind: tar
  url: gnome_downloads:gnome-video-effects/0.5/gnome-video-effects-0.5.0.tar.xz
  ref: 4dc68e9b38fdfc1e8e0414e2d7ee83ace78efdee76f30506cc9dcd07394ad0c8
build-depends:
- freedesktop-sdk.bst:components/perl-xml-parser.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- freedesktop-sdk.bst:components/gstreamer.bst
- freedesktop-sdk.bst:bootstrap-import.bst
