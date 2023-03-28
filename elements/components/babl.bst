kind: meson
sources:
- kind: tar
  url: gimp:babl/0.1/babl-0.1.98.tar.xz
  ref: f3b222f84e462735de63fa9c3651942f2b78fd314c73a22e05ff7c73afd23af1
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
