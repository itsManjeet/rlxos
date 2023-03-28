kind: autotools
sources:
- kind: tar
  url: gnome_downloads:startup-notification/0.12/startup-notification-0.12.tar.xz
  ref: 4bd1363a2f3b3eb2c4f7fc33b4977bb9c12b4741206f05109b0ff2b3b30b6bc0
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- freedesktop-sdk.bst:components/xcb-util.bst
- freedesktop-sdk.bst:components/xorg-lib-x11.bst
- freedesktop-sdk.bst:bootstrap-import.bst
