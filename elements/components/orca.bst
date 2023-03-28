kind: autotools
sources:
- kind: tar
  url: gnome_downloads:orca/43/orca-43.1.tar.xz
  ref: f658e049ce169273b84346810424d6f509291f05d7ecc3a77a03d912aa3e6840
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- components/pyatspi.bst
- components/speech-dispatcher.bst
- components/at-spi2-core.bst
- components/gobject-introspection.bst
- components/gtk+-3.bst
- components/pygobject.bst
- components/yelp-tools.bst
- freedesktop-sdk.bst:bootstrap-import.bst
