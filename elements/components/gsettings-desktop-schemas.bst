kind: meson

sources:
- kind: tar
  url: 
    gnome_downloads:gsettings-desktop-schemas/45/gsettings-desktop-schemas-45.0.tar.xz
  ref: 365c8d04daf79b38c8b3dc9626349a024f9e4befdd31fede74b42f7a9fbe0ae2
build-depends:
- components/gobject-introspection.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/glib.bst
- freedesktop-sdk.bst:bootstrap-import.bst
