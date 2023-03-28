kind: autotools

sources:
- kind: tar
  url: github_files:sass/libsass/archive/3.6.4.tar.gz

  ref: f9484d9a6df60576e791566eab2f757a97fd414fce01dd41fc0a693ea5db2889
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:bootstrap-import.bst
