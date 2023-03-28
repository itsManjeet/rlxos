kind: autotools

sources:
- kind: tar
  url: sourceforge:libmtp/libmtp/1.1.18/libmtp-1.1.18.tar.gz

  ref: 7280fe50c044c818a06667f45eabca884deab3193caa8682e0b581e847a281f0
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:components/libusb.bst
- freedesktop-sdk.bst:bootstrap-import.bst
