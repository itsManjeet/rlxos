kind: manual

build-depends:
- freedesktop-sdk.bst:components/python3-pip.bst

depends:
- components/libgbinder.bst
- freedesktop-sdk.bst:components/pkg-config.bst
- freedesktop-sdk.bst:components/cython.bst
- freedesktop-sdk.bst:components/python3.bst

config:
  build-commands:
  - python3 setup.py build_ext --cython

  install-commands:
  - python3 setup.py install --prefix=%{prefix} --root=%{install-root}

sources:
- kind: git_tag
  url: github:erfanoabdi/gbinder-python.git
  track: 1.1.1
  ref: 1.1.1-0-g423dc366561c82515f4f2f46017535e7d81ce5b1
