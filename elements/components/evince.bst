kind: meson

sources:
- kind: tar
  url: gnome_downloads:evince/44/evince-44.1.tar.xz
  ref: 15afd3bb15ffb38fecab34c23350950ad270ab03a85b94e333d9dd7ee6a74314
build-depends:
- components/gtk-doc.bst
- freedesktop-sdk.bst:components/desktop-file-utils.bst
- freedesktop-sdk.bst:components/itstool.bst
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
- freedesktop-sdk.bst:components/poppler.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dcomics=disabled
    -Ddjvu=disabled
    -Ddvi=disabled
    -Dintrospection=true
    -Dgtk_doc=false
    -Dnautilus=false
