kind: meson

sources:
- kind: git_tag
  url: freedesktop:bolt/bolt.git
  track: master

  ref: 0.9.5-4-gd3e0fd43fd99fc51488154f72cb15ff0481d3a86
depends:
- freedesktop-sdk.bst:components/polkit.bst
- freedesktop-sdk.bst:components/systemd.bst

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- freedesktop-sdk.bst:components/python3-setuptools.bst
