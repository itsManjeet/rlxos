kind: autotools

sources:
- kind: tar
  url: libburnia:libburn-1.5.4.tar.gz

  ref: 525059d10759c5cb8148eebc863bb510e311c663603da7bd2d21c46b7cf63b54
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:bootstrap-import.bst
