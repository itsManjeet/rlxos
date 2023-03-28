kind: autotools

sources:
- kind: tar
  url: github_files:adrienverge/openfortivpn/archive/refs/tags/v1.16.0.tar.gz

  ref: 599b1e159a03be557242aa0e693bb7ddbadf2a4a2b3ffcf77dc15459fe7f6cd6
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:bootstrap-import.bst
- freedesktop-sdk.bst:components/openssl.bst
