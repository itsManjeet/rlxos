kind: meson

sources:
- kind: tar
  url: gnome_downloads:sushi/45/sushi-45.0.tar.xz
  ref: 6a5f14b05a3471fe43853cc2b0e1ae5484d7f9f86f7ea376179829b9bf4ac1dd
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- components/evince.bst

depends:
- components/gjs.bst
- components/gtk+-3.bst
- components/gtksourceview-4.bst
- components/webkit2gtk-4.1.bst
- freedesktop-sdk.bst:components/gstreamer.bst
- freedesktop-sdk.bst:components/gstreamer-plugins-base.bst
- freedesktop-sdk.bst:bootstrap-import.bst
