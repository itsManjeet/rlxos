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
  - v4.3

  exclude:
  - "*rc*"
  ref: v2.1.0-8510-gc35e74f4ccde619cd21b2215a5a4e9a0177cb418
