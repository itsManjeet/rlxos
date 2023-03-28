kind: manual

build-depends:
- freedesktop-sdk.bst:components/go.bst
- freedesktop-sdk.bst:bootstrap-import.bst
- freedesktop-sdk.bst:components/pkg-config.bst

runtime-depends:
- freedesktop-sdk.bst:snap-images/squashfs-tools.bst
- freedesktop-sdk.bst:components/desktop-file-utils.bst

depends:
- freedesktop-sdk.bst:components/systemd.bst

sources:
- kind: git_tag
  url: https://github.com/probonopd/go-appimage.git
  track: master

  ref: continuous-0-gbb5081a46c15ebb828b5cb0bb0445e1e2f6484ad
- kind: go-vendor
  ref: 2ad87ad7f3426145d963f1a1186591f99fcd43765d2493b937aa56a3d04bb0cc
- kind: local
  path: files/appimaged

config:
  build-commands:
  - go build -trimpath -ldflags="-s -w" github.com/probonopd/go-appimage/src/appimaged

  install-commands:
  - install -v -D -m0755 appimaged -t %{install-root}%{bindir}/

  - |
    unitdir="$(pkg-config --variable=systemduserunitdir systemd)"
    install -Dm644 -t %{install-root}${unitdir} appimaged.service

  - |
    presetdir="$(pkg-config --variable=systemduserpresetdir systemd)"
    install -Dm644 -t %{install-root}${presetdir} appimaged.preset
