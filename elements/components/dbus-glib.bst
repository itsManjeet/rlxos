kind: autotools
sources:
- kind: tar
  url: https://dbus.freedesktop.org/releases/dbus-glib/dbus-glib-0.110.tar.gz
  ref: 7ce4760cf66c69148f6bd6c92feaabb8812dee30846b24cd0f7395c436d7e825
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- components/glib.bst
- freedesktop-sdk.bst:components/dbus.bst
- freedesktop-sdk.bst:bootstrap-import.bst
