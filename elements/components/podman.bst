kind: make

build-depends:
- freedesktop-sdk.bst:components/pkg-config.bst
- freedesktop-sdk.bst:components/go.bst
- freedesktop-sdk.bst:components/go-md2man.bst
- freedesktop-sdk.bst:components/git-minimal.bst
- freedesktop-sdk.bst:components/python3.bst
- freedesktop-sdk.bst:components/standard-streams.bst

depends:
- freedesktop-sdk.bst:components/libseccomp.bst
- freedesktop-sdk.bst:components/systemd-libs.bst
- freedesktop-sdk.bst:components/gpgme.bst
- freedesktop-sdk.bst:bootstrap-import.bst

runtime-depends:
- freedesktop-sdk.bst:components/conmon.bst
- freedesktop-sdk.bst:components/cni.bst
- freedesktop-sdk.bst:components/crun.bst
- freedesktop-sdk.bst:components/slirp4netns.bst
- freedesktop-sdk.bst:components/fuse-overlayfs.bst
- freedesktop-sdk.bst:components/iptables.bst
- freedesktop-sdk.bst:components/podman-config.bst

environment:
  GOPATH: "%{build-root}"

variables:
  ldflags_defaults: ""
  optimize-debug: "false"
  compress-debug: "false"
  command-subdir: src/github.com/containers/podman

sources:
- kind: git_tag
  url: github:containers/podman.git
  directory: src/github.com/containers/podman
  track: main
  track-extra:
  - v4.5

  exclude:
  - "*rc*"
  ref: v4.5.0-10-g5d1f5d79ac74bc04f9d83c0a73714abd608c1599
