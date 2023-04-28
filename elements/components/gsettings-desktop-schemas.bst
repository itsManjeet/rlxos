kind: meson

sources:
- kind: tar
  url: gnome_downloads:gsettings-desktop-schemas/44/gsettings-desktop-schemas-44.0.tar.xz
  ref: eb2de45cad905994849e642a623adeb75d41b21b0626d40d2a07b8ea281fec0e
build-depends:
- components/gobject-introspection.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/glib.bst
- freedesktop-sdk.bst:bootstrap-import.bst
