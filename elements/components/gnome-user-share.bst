kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-user-share/43/gnome-user-share-43.0.tar.xz
  ref: 0df306aa0558313f353ef7f51bfa27c036281adc45677e1cfbfa7c9f861538ce
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/glib.bst
- freedesktop-sdk.bst:bootstrap-import.bst
- freedesktop-sdk.bst:components/systemd.bst
