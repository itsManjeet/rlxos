kind: autotools
sources:
- kind: tar
  url: dbmx:kyotocabinet/pkg/kyotocabinet-1.2.76.tar.gz
  ref: 812a2d3f29c351db4c6f1ff29d94d7135f9e601d7cc1872ec1d7eed381d0d23c
- kind: patch
  path: files/kyotocabinet/cpp-14.patch
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- freedesktop-sdk.bst:bootstrap-import.bst
