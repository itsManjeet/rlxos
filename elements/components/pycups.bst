kind: pip

sources:
- kind: tar
  url: github_files:OpenPrinting/pycups/releases/download/v2.0.1/pycups-2.0.1.tar.gz

  ref: 57434ce5f62548eb12949ca8217f066f4eeb21a5d6ab8b13471dce350e380c90
build-depends:
- freedesktop-sdk.bst:components/python3-pip.bst

depends:
- freedesktop-sdk.bst:components/cups.bst
- freedesktop-sdk.bst:components/python3.bst
