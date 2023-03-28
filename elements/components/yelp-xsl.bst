kind: autotools
sources:
- kind: tar
  url: gnome_downloads:yelp-xsl/42/yelp-xsl-42.1.tar.xz
  ref: 238be150b1653080ce139971330fd36d3a26595e0d6a040a2c030bf3d2005bcd
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- freedesktop-sdk.bst:components/itstool.bst
- freedesktop-sdk.bst:bootstrap-import.bst
