kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-console/45/gnome-console-45.beta.tar.xz
  ref: 24cbd5680e525c2c0c57ad8d8c1ad199ef5b45b1ff1c80be22a37848e46e93ac
build-depends:
- freedesktop-sdk.bst:components/desktop-file-utils.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

runtime-depends:
- components/adobe-source-code-pro-fonts.bst
- components/adwaita-icon-theme.bst

depends:
- components/libgtop.bst
- components/vte.bst
- components/nautilus.bst
- components/gtk.bst
- components/libadwaita.bst
- freedesktop-sdk.bst:bootstrap-import.bst
