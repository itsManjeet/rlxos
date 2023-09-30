kind: pip


build-depends:
- freedesktop-sdk.bst:components/python3-pip.bst
depends:
- freedesktop-sdk.bst:components/python3-pygments.bst
- freedesktop-sdk.bst:components/python3.bst


sources:
- kind: git_tag
  url: github:jquast/wcwidth
  track: master
  ref: 0.2.8-0-g2c9ab7c9d6905c0d4364071011a3168a3cbcadf2
