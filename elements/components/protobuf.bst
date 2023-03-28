kind: autotools

sources:
- kind: tar
  url: github_files:protocolbuffers/protobuf/releases/download/v21.2/protobuf-all-21.2.tar.gz

  ref: 9ae699200f3a80c735f9dc3b20e46d447584266f4601403e8fe5b97005f204dd
build-depends:
- freedesktop-sdk.bst:components/python3-pip.bst
- freedesktop-sdk.bst:components/python3-six.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:components/python3.bst

config:
  install-commands:
    (>):
    - python -m pip install --no-build-isolation --root=%{install-root} --prefix=%{prefix}
      python/
