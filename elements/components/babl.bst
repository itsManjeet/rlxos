kind: meson
sources:
- kind: tar
  url: gimp:babl/0.1/babl-0.1.106.tar.xz
  ref: d325135d3304f088c134cc620013acf035de2e5d125a50a2d91054e7377c415f
build-depends:
- components/gobject-introspection.bst
- components/vala.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- freedesktop-sdk.bst:components/lcms.bst
- freedesktop-sdk.bst:bootstrap-import.bst

(?):
- (arch == "i686" or arch == "ppc64le"):
    variables:
      optimize-debug: 'false'
