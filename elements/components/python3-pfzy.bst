kind: pip

build-depends:
- freedesktop-sdk.bst:components/python3-pip.bst
depends:
- freedesktop-sdk.bst:components/python3-poetry-core.bst
- freedesktop-sdk.bst:components/python3.bst

sources:
- kind: tar
  url: https://files.pythonhosted.org/packages/source/p/pfzy/pfzy-0.3.4.tar.gz
  ref: 717ea765dd10b63618e7298b2d98efd819e0b30cd5905c9707223dceeb94b3f1
