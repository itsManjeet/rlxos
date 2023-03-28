kind: meson

sources:
- kind: tar
  url: gnome_downloads:sushi/43/sushi-43.0.tar.xz
  ref: 57848526149ab1c784fb92fbc934c3514fe522aba649d5d9fedec7e1b147527b
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- components/evince.bst

depends:
- components/gjs.bst
- components/gst-plugins-base.bst
- components/gtk+-3.bst
- components/gtksourceview-4.bst
- components/webkit2gtk-4.1.bst
- freedesktop-sdk.bst:components/gstreamer.bst
- freedesktop-sdk.bst:bootstrap-import.bst
