kind: pip

sources:
- kind: tar
  url: pypi:c1/47/dfc9c342c9842bbe0036c7f763d2d6686bcf5eb1808ba3e170afdb282210/pyparsing-2.4.7.tar.gz

  ref: c203ec8783bf771a155b207279b9bccb8dea02d8f0c9e5f8ead507bc3246ecc1
build-depends:
- freedesktop-sdk.bst:components/python3-pip.bst

depends:
- freedesktop-sdk.bst:components/python3.bst
- freedesktop-sdk.bst:bootstrap-import.bst
