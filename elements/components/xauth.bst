kind: autotools

sources:
- kind: tar
  url: freedesktop_files:xorg/app/xauth/-/archive/xauth-1.1.2/xauth-xauth-1.1.2.tar.bz2
  ref: 271ba0138bfc7c32d33fa49d19134214c4283a16c26848b8237b921a23e9d44d

depends:
- components/xorg-lib-xmu.bst
- freedesktop-sdk.bst:bootstrap-import.bst
- freedesktop-sdk.bst:components/xorg-lib-x11.bst
- freedesktop-sdk.bst:components/xorg-lib-xau.bst
- freedesktop-sdk.bst:components/xorg-lib-xext.bst

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
- freedesktop-sdk.bst:components/xorg-util-macros.bst
