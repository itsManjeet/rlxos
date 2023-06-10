kind: pip


build-depends:
- freedesktop-sdk.bst:components/python3-pip.bst
depends:
- components/python3-wcwidth.bst
- freedesktop-sdk.bst:components/python3-pygments.bst
- freedesktop-sdk.bst:components/python3.bst


sources:
- kind: git_tag
  url: github:jonathanslenders/python-prompt-toolkit
  track: master
  ref: 3.0.38-5-g5b3dd6dbbd72ac8323e749cc12e6aa2d7c7411af
