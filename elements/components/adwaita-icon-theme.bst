kind: autotools
sources:
- kind: tar
  url: gnome_downloads:adwaita-icon-theme/43/adwaita-icon-theme-43.beta.1.tar.xz
  ref: 6f9c7f41de9acaa42a62d90582f682aae24db9347f8c49f2c0cec5fb2b5103c2
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- components/gtk+-3.bst
- components/librsvg.bst
- freedesktop-sdk.bst:bootstrap-import.bst
