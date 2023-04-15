kind: autotools

sources:
- kind: git_tag
  url: https://repo.or.cz/tinycc.git
  track: mob

  ref: release_0_9_27-1016-gb006b9833466933660e1c052454239e4ca3e3f4d
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:bootstrap-import.bst
