kind: autotools
sources:
- kind: tar
  url: gnome_downloads:orca/44/orca-44.1.tar.xz
  ref: f5ed6551d72f897b21248d433085a7b817accbb0296a84c3e851d91fb2eee4de
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
