kind: autotools

sources:
- kind: tar
  url: ftp_gnu_org:libcdio/libcdio-paranoia-10.2+2.0.1.tar.gz

  ref: 28d7d00e4a83d0221acda0fd2eb3e3240bf094db4c00a85998922201939fa952
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- components/libcdio.bst
- freedesktop-sdk.bst:bootstrap-import.bst
