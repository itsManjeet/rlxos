kind: autotools

sources:
- kind: tar
  url: github_files:libimobiledevice/libusbmuxd/releases/download/2.0.2/libusbmuxd-2.0.2.tar.bz2

  ref: cc6a808553da4efa9fa5638be256d5ae020498795d9d260d280b87074e799b20
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- components/plist.bst
- freedesktop-sdk.bst:bootstrap-import.bst
