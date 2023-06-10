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
  ref: 0.2.6-0-gf0232e5adfbcd7473021a5672c61ed79fee667f0
