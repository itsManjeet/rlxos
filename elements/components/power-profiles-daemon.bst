kind: meson

sources:
- kind: tar
  url: freedesktop_files:hadess/power-profiles-daemon/uploads/329f1ed3b068f6c59b8441f01a4e711a/power-profiles-daemon-0.8.1.tar.xz

  ref: 091128f78c35d214cf6b38260b9a6008c1ad550b28558f241e2cb746a8be7157
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/upower.bst
- freedesktop-sdk.bst:components/libgudev.bst
- freedesktop-sdk.bst:components/systemd.bst
- freedesktop-sdk.bst:bootstrap-import.bst
