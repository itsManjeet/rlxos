kind: autotools
sources:
- kind: tar
  url: gnome_downloads:vala/0.36/vala-0.36.20.tar.xz
  ref: be960a87841d85ff76cbd0e10eb691675190e54bd690d76982b3fb94a1fc67a7
build-depends:
- freedesktop-sdk.bst:components/bison.bst
- freedesktop-sdk.bst:components/flex.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- components/glib.bst
- freedesktop-sdk.bst:bootstrap-import.bst
