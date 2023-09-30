kind: autotools
sources:
- kind: tar
  url: gnome_downloads:orca/45/orca-45.0.tar.xz
  ref: c68a205f8dac04e9494d6cbfcbf6097bffecd2b8f7c4b91009bd448134e98536
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
