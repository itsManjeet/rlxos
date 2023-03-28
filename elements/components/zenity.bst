kind: meson
sources:
- kind: tar
  url: https://gitlab.gnome.org/GNOME/zenity/-/archive/3.43.0/zenity-3.43.0.tar.gz

  ref: d2d5c8e0b3057fa84a4a82e4fa72e90858f5e13b009d3e382343e7fef20a3e41
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- freedesktop-sdk.bst:components/itstool.bst

depends:
- components/webkit2gtk-4.1.bst
- components/libnotify.bst

variables:
  meson-local: >-
    -Dlibnotify=true
    -Dwebkitgtk=true
