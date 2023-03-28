kind: meson

sources:
- kind: tar
  url: gnome_downloads:gsettings-desktop-schemas/43/gsettings-desktop-schemas-43.0.tar.xz
  ref: 5d5568282ab38b95759d425401f7476e56f8cbf2629885587439f43bd0b84bbe
build-depends:
- components/gobject-introspection.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/glib.bst
- freedesktop-sdk.bst:bootstrap-import.bst
