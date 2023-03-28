kind: meson
sources:
- kind: tar
  url: gnome_downloads:yelp-tools/42/yelp-tools-42.1.tar.xz
  ref: 3e496a4020d4145b99fd508a25fa09336a503a4e8900028421e72c6a4b11f905
build-depends:
- freedesktop-sdk.bst:components/m4.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/yelp-xsl.bst
- freedesktop-sdk.bst:bootstrap-import.bst
- freedesktop-sdk.bst:components/python3-lxml.bst
