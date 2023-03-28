kind: manual

sources:
- kind: tar
  url: cpan:authors/id/W/WB/WBRASWELL/Parse-Yapp-1.21.tar.gz

  ref: 3810e998308fba2e0f4f26043035032b027ce51ce5c8a52a8b8e340ca65f13e5
depends:
- freedesktop-sdk.bst:components/perl.bst
- freedesktop-sdk.bst:bootstrap-import.bst

config:
  configure-commands:
  - perl Makefile.PL PREFIX="%{prefix}" DESTDIR="%{install-root}"
  install-commands:
  - make -j1 install
