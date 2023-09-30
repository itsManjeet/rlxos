kind: cmake
sources:
- kind: git_tag
  track: master
  url: github:itsManjeet/srclang.git

  ref: v0.0.1-37-g44c3a61e306fca3faea4adf8bb377741f1c6f30d

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst


depends:
- freedesktop-sdk.bst:components/libffi.bst
- freedesktop-sdk.bst:bootstrap-import.bst

config:
  install-commands:
  - install -Dm0755 -t "%{install-root}%{bindir}" %{build-dir}/srclang
  - install -Dm0644 -t "%{install-root}/usr/lib/srclang/" modules/*.src
