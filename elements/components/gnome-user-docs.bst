kind: autotools
sources:
- kind: tar
  url: gnome_downloads:gnome-user-docs/43/gnome-user-docs-43.0.tar.xz
  ref: 3607160effd6f91e25a8798b57defb2099dd70b8fee4e7e2f20f2637ac28caee
build-depends:
- components/yelp-tools.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- freedesktop-sdk.bst:bootstrap-import.bst
