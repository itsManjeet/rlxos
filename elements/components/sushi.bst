kind: meson

sources:
- kind: tar
  url: gnome_downloads:sushi/44/sushi-44.2.tar.xz
  ref: 6c002fe0aea19027ba448b5aec94d5cd753c9752f996ee033152428738ea43e9
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
