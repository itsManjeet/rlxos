kind: meson

sources:
- kind: tar
  url: github_files:endlessm/mogwai/archive/Release_3.9.4.tar.gz

  ref: 9cd4ba92cade0d998618ae18458b12acc2db15350ae2170823ccd1739e745583
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/networkmanager.bst
- components/glib.bst
- components/libsoup-2.4.bst
- freedesktop-sdk.bst:components/systemd.bst
- freedesktop-sdk.bst:bootstrap-import.bst
