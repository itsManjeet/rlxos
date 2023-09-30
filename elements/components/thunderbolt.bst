kind: meson

sources:
- kind: git_tag
  url: freedesktop:bolt/bolt.git
  track: master

  ref: 0.9.6-0-gf03c50b22ae3fda26711ddabd91e2c5dd8103478
depends:
- freedesktop-sdk.bst:components/polkit.bst
- freedesktop-sdk.bst:components/systemd.bst

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- freedesktop-sdk.bst:components/python3-setuptools.bst
