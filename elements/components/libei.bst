kind: meson

sources:
- kind: tar
  url: freedesktop_files:libinput/libei/-/archive/1.0.901/libei-1.0.901.tar.gz

  ref: 11be2b3d4354e8642bc33eed6500fe02e79f99f3fc9d51a01e6cba44b754254d
variables:
  meson-local: >-
    -D tests=disabled

build-depends:
- freedesktop-sdk.bst:components/python3-attrs.bst
- freedesktop-sdk.bst:components/python3-jinja2.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- freedesktop-sdk.bst:components/systemd.bst
- freedesktop-sdk.bst:bootstrap-import.bst
