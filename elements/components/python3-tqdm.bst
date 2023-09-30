kind: pip

build-depends:
- freedesktop-sdk.bst:components/python3-pip.bst
depends:
- freedesktop-sdk.bst:components/python3.bst

sources:
- kind: git_tag
  url: github:tqdm/tqdm.git
  track: master
  ref: v4.66.1-0-g4c956c20b83be4312460fc0c4812eeb3fef5e7df
