kind: meson

sources:
- kind: tar
  url: gnome_downloads:evince/43/evince-43.1.tar.xz
  ref: 6d75ca62b73bfbb600f718a098103dc6b813f9050b9594be929e29b4589d2335
build-depends:
- components/appstream-glib.bst
- components/gtk-doc.bst
- freedesktop-sdk.bst:components/itstool.bst
- freedesktop-sdk.bst:components/poppler.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/gspell.bst
- components/libgxps.bst
- components/nautilus.bst
- components/adwaita-icon-theme.bst
- components/glib.bst
- components/gtk+-3.bst
- components/libhandy.bst
- components/libsecret.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dcomics=disabled
    -Ddjvu=disabled
    -Ddvi=disabled
    -Dintrospection=true
    -Dgtk_doc=false
    -Dnautilus=false
