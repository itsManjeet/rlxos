kind: autotools

sources:
- kind: tar
  url: freedesktop_files:xorg/app/setxkbmap/-/archive/setxkbmap-1.3.4/setxkbmap-setxkbmap-1.3.4.tar.bz2
  ref: e8793f21830a059e21d7e3617a50a50a1e91db495e7a4689b84fe2619b7279bc

build-depends:
- freedesktop-sdk.bst:components/xorg-util-macros.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:components/xorg-lib-x11.bst
- freedesktop-sdk.bst:components/xorg-lib-xkbfile.bst
- freedesktop-sdk.bst:components/xorg-lib-xrandr.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  conf-local: >-
    --disable-silent-rules
