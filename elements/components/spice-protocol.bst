kind: meson
sources:
- kind: tar
  url: spice:releases/spice-protocol-0.14.4.tar.xz
  ref: 04ffba610d9fd441cfc47dfaa135d70096e60b1046d2119d8db2f8ea0d17d912
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- freedesktop-sdk.bst:bootstrap-import.bst
