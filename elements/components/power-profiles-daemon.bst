kind: meson

sources:
- kind: tar
  url: 
    freedesktop_files:hadess/power-profiles-daemon/uploads/1f2ea40547b2af8d255875d7085211e5/power-profiles-daemon-0.13.tar.xz

  ref: 0f9c1d2274350d44a95daafa7184b1a1a3f072bd1c70a100eb678ac051afcdcb
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/upower.bst
- freedesktop-sdk.bst:components/libgudev.bst
- freedesktop-sdk.bst:components/polkit.bst
- freedesktop-sdk.bst:components/systemd.bst
- freedesktop-sdk.bst:bootstrap-import.bst
