kind: autotools
sources:
- kind: tar
  url: gnome_downloads:libgtop/2.41/libgtop-2.41.1.tar.xz
  ref: 43ea9ad13f7caf98303e64172b191be9b96bab340b019deeec72251ee140fe3b
build-depends:
- components/gtk-doc.bst
- freedesktop-sdk.bst:components/texinfo.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- components/glib.bst
- freedesktop-sdk.bst:bootstrap-import.bst
environment:
  CC: gcc -std=c99
config:
  install-commands:
    (>):
    - rm "%{install-root}/usr/share/info/dir"
