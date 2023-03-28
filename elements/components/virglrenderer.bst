kind: meson

sources:
- kind: tar
  url: freedesktop:virgl/virglrenderer/-/archive/virglrenderer-0.9.1/virglrenderer-virglrenderer-0.9.1.tar.bz2

  ref: 860cc3f0f1a448542a812b6e13909824eb3140b7b3283d068e9640487d50e6c0
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- freedesktop-sdk.bst:components/dummy-gbm.bst
- freedesktop-sdk.bst:components/libdrm.bst
- freedesktop-sdk.bst:components/libepoxy.bst
- freedesktop-sdk.bst:bootstrap-import.bst
