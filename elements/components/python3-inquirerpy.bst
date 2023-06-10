kind: pip

build-depends:
- freedesktop-sdk.bst:components/python3-pip.bst
depends:
- components/python3-pfzy.bst
- components/python3-prompt-toolkit.bst
- freedesktop-sdk.bst:components/python3-poetry-core.bst
- freedesktop-sdk.bst:components/python3.bst

sources:
- kind: tar
  url: https://files.pythonhosted.org/packages/source/I/InquirerPy/InquirerPy-0.3.4.tar.gz
  ref: 89d2ada0111f337483cb41ae31073108b2ec1e618a49d7110b0d7ade89fc197e
