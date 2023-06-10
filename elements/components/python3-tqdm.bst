kind: pip

build-depends:
- freedesktop-sdk.bst:components/python3-pip.bst
depends:
- freedesktop-sdk.bst:components/python3.bst

sources:
- kind: git_tag
  url: github:tqdm/tqdm.git
  track: master
  ref: v4.65.0-0-g0bb91857eca0d4aea08f66cf1c8949abe0cd6b7a
