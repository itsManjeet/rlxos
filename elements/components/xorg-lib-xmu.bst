kind: autotools

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
- freedesktop-sdk.bst:components/xorg-util-macros.bst

depends:
- freedesktop-sdk.bst:bootstrap-import.bst
- freedesktop-sdk.bst:components/xorg-lib-x11.bst
- freedesktop-sdk.bst:components/xorg-lib-xext.bst
- freedesktop-sdk.bst:components/xorg-lib-xt.bst

sources:
- kind: tar
  url: freedesktop:xorg/lib/libxmu/-/archive/libXmu-1.1.4/libxmu-libXmu-1.1.4.tar.bz2
  ref: 266dcc1b7bde4dc8341b6cd1ba2253ac5f01b3e1791e15af957c8a316ade2f8c
