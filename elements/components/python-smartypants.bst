kind: pip

sources:
- kind: tar
  url: github_files:leohemsted/smartypants.py/archive/refs/tags/v2.0.1.tar.gz

  ref: b98191911ff3b4144ef8ad53e776a2d0ad24bd508a905c6ce523597c40022773
build-depends:
- freedesktop-sdk.bst:components/python3-pip.bst

depends:
- freedesktop-sdk.bst:components/python3.bst
