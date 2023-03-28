kind: cmake
sources:
- kind: git_tag
  track: master
  url: github:itsManjeet/srclang.git

  ref: v0.0.1-5-gbff83cded1c1bbf4147d483f4ffae1cf36692ebf

- kind: patch
  path: patches/srclang/dynamic.patch


build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst


depends:
- components/libtcc.bst
- freedesktop-sdk.bst:bootstrap-import.bst

config:
  install-commands:
  - install -Dm0755 -t "%{install-root}%{bindir}" %{build-dir}/srclang
  - install -Dm0644 -t "%{install-root}/usr/lib/srclang/" modules/std.src
