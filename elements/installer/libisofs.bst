kind: autotools

sources:
- kind: tar
  url: libburnia:libisofs-1.5.4.tar.gz

  ref: aaa0ed80a7501979316f505b0b017f29cba0ea5463b751143bad2c360215a88e
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:bootstrap-import.bst
