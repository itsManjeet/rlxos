kind: autotools

sources:
- kind: tar
  url: gnome_downloads:mobile-broadband-provider-info/20221107/mobile-broadband-provider-info-20221107.tar.xz
  ref: d93392566c347a96eed95da8c66a5da0dd94f4115cfb3a305ff2682c64cfd810
build-depends:
- freedesktop-sdk.bst:components/libxslt.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:bootstrap-import.bst
