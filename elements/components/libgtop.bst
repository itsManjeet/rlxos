kind: autotools
sources:
- kind: tar
  url: gnome_downloads:libgtop/2.40/libgtop-2.40.0.tar.xz
  ref: 78f3274c0c79c434c03655c1b35edf7b95ec0421430897fb1345a98a265ed2d4
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
