kind: autotools
sources:
- kind: tar
  url: github_files:williamh/dotconf/archive/v1.3.tar.gz
  ref: 7f1ecf40de1ad002a065a321582ed34f8c14242309c3547ad59710ae3c805653
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- freedesktop-sdk.bst:bootstrap-import.bst
