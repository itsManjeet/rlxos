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
  ref: 3.0.39-0-g490cf900188df357611cdc9358256be0e5ce2e16
