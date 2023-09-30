kind: autotools

sources:
- kind: tar
  url: gnome_downloads:gspell/1.12/gspell-1.12.2.tar.xz
  ref: b4e993bd827e4ceb6a770b1b5e8950fce3be9c8b2b0cbeb22fdf992808dd2139
build-depends:
- components/gobject-introspection.bst
- components/gtk-doc.bst
- components/vala.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- components/enchant-2.bst
- components/gtk+-3.bst
- freedesktop-sdk.bst:components/icu.bst
- freedesktop-sdk.bst:bootstrap-import.bst
