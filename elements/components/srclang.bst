kind: cmake
sources:
- kind: git_tag
  track: master
  url: github:itsManjeet/srclang.git

  ref: v0.0.1-11-g7f53de228d79d24113e5fc2d350ce7fe2b8a7694

- kind: patch
  path: patches/srclang/dynamic.patch


build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst


depends:
- components/libtcc.bst
- freedesktop-sdk.bst:components/libffi.bst
- freedesktop-sdk.bst:bootstrap-import.bst

config:
  install-commands:
  - install -Dm0755 -t "%{install-root}%{bindir}" %{build-dir}/srclang
  - install -Dm0644 -t "%{install-root}/usr/lib/srclang/" modules/*.src
