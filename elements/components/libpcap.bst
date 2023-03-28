kind: autotools

sources:
- kind: tar
  url: tcpdump:release/libpcap-1.10.1.tar.gz

  ref: ed285f4accaf05344f90975757b3dbfe772ba41d1c401c2648b7fa45b711bdd4
build-depends:
- freedesktop-sdk.bst:components/bison.bst
- freedesktop-sdk.bst:components/flex.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:bootstrap-import.bst
