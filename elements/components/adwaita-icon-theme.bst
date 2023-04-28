kind: autotools
sources:
- kind: tar
  url: gnome_downloads:adwaita-icon-theme/44/adwaita-icon-theme-44.0.tar.xz
  ref: 4889c5601bbfecd25d80ba342209d0a936dcf691ee56bd6eca4cde361f1a664c
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- components/gtk+-3.bst
- components/librsvg.bst
- freedesktop-sdk.bst:bootstrap-import.bst
