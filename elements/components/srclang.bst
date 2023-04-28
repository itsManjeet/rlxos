kind: cmake
sources:
- kind: git_tag
  track: master
  url: github:itsManjeet/srclang.git

  ref: v0.0.1-14-gf6e96a929005fff6ea0d7f7f6ec34edd2ee00b64

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst


depends:
- freedesktop-sdk.bst:components/libffi.bst
- freedesktop-sdk.bst:bootstrap-import.bst

config:
  install-commands:
  - install -Dm0755 -t "%{install-root}%{bindir}" %{build-dir}/srclang
  - install -Dm0644 -t "%{install-root}/usr/lib/srclang/" modules/*.src
