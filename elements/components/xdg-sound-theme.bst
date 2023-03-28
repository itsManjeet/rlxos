kind: autotools

sources:
- kind: tar
  url: freedesktop:xdg/xdg-sound-theme/-/archive/0.8/xdg-sound-theme-0.8.tar.bz2

  ref: 0fabaa8fd86d2887380590a3f6e305a3dde5c41783dcae9a6ba67122d51b55f9
build-depends:
- components/intltool.bst
- components/glib.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
