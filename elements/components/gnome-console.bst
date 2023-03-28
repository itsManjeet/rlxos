kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-console/43/gnome-console-43.0.tar.xz
  ref: b9642485a37a70e82cc10553b0e2681756ba361ff5e4cbf3182f150231fea99e
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
