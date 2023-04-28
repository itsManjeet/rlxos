kind: meson
sources:
- kind: tar
  url: gimp:babl/0.1/babl-0.1.104.tar.xz
  ref: 22e38e1d19c5391abc8ccf936033a9d035e8a8ec7523e5cd76a4c01137d7160c
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
