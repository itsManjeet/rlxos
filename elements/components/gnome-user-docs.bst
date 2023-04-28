kind: autotools
sources:
- kind: tar
  url: gnome_downloads:gnome-user-docs/44/gnome-user-docs-44.1.tar.xz
  ref: 93f3294d43fd22f9962ccf6bd17ff64eae78a6ca063fe6c1e9bc58d00f34e3a8
build-depends:
- components/yelp-tools.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- freedesktop-sdk.bst:bootstrap-import.bst
