kind: autotools

sources:
- kind: tar
  url: gnome_downloads:mobile-broadband-provider-info/20230416/mobile-broadband-provider-info-20230416.tar.xz
  ref: e3e140aa2db769b299d1df86a890e948ab99d4d38831302c452d1fb7f8568aec
build-depends:
- freedesktop-sdk.bst:components/libxslt.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:bootstrap-import.bst
