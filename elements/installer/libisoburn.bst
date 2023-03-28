kind: autotools

sources:
- kind: tar
  url: libburnia:libisoburn-1.5.4.tar.gz

  ref: 2d89846d43880f17fa591c53b3bea42ffb803628e4e630c680fc2c9184f79132
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:bootstrap-import.bst
- installer/libisofs.bst
- installer/libburn.bst
