kind: meson

sources:
- kind: tar
  url: gnome_downloads:tecla/45/tecla-45.0.tar.xz
  ref: 5c02bb4019b1cffb5663da6107503eff853836a8783dd4705dd04a49f7adc25b
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/gtk.bst
- components/libadwaita.bst
- freedesktop-sdk.bst:components/libxkbcommon.bst
- freedesktop-sdk.bst:components/wayland.bst
- freedesktop-sdk.bst:bootstrap-import.bst
