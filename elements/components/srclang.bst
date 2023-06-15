kind: cmake
sources:
- kind: git_tag
  track: master
  url: github:itsManjeet/srclang.git

  ref: v0.0.1-25-g8c0a1f79f4ecec12f020d2d3ac3ab3a07f227c3e

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst


depends:
- freedesktop-sdk.bst:components/libffi.bst
- freedesktop-sdk.bst:bootstrap-import.bst

config:
  install-commands:
  - install -Dm0755 -t "%{install-root}%{bindir}" %{build-dir}/srclang
  - install -Dm0644 -t "%{install-root}/usr/lib/srclang/" modules/*.src
