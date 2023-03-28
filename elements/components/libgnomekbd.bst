kind: autotools

sources:
- kind: tar
  url: gnome_downloads:libgnomekbd/3.28/libgnomekbd-3.28.1.tar.xz
  ref: 22dc59566d73c0065350f5a97340e62ecc7b08c4df19183804bb8be24c8fe870
build-depends:
- components/gobject-introspection.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- components/libxklavier.bst
- components/gtk+-3.bst
- freedesktop-sdk.bst:bootstrap-import.bst
