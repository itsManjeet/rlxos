kind: autotools
sources:
- kind: tar
  url: gnome_downloads:gnome-user-docs/45/gnome-user-docs-45.0.tar.xz
  ref: ff1cbbdc0e109e99b860a8fbe335b73948e0be9cdb7ed9c384ab92c8243d3ce1
build-depends:
- components/yelp-tools.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- freedesktop-sdk.bst:bootstrap-import.bst
