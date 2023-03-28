kind: autotools

sources:
- kind: tar
  url: freedesktop_people:~svu/libxklavier-5.4.tar.bz2

  ref: 17a34194df5cbcd3b7bfd0f561d95d1f723aa1c87fca56bc2c209514460a9320
build-depends:
- components/intltool.bst
- components/gobject-introspection.bst
- components/gtk-doc.bst
- freedesktop-sdk.bst:components/iso-codes.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:components/libxml2.bst
- freedesktop-sdk.bst:components/xorg-app-xkbcomp.bst
- freedesktop-sdk.bst:components/xorg-lib-x11.bst
- freedesktop-sdk.bst:components/xorg-lib-xi.bst
- freedesktop-sdk.bst:bootstrap-import.bst
