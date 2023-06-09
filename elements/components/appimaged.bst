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

  ref: continuous-0-g785b52511085b37e09e967c0bc2ebd7f9401e6b9
- kind: go-vendor
  ref: 0e8a2b335ce1c8ff0b505e8f036042aa5d2e04e3891b33f034facc9f26ac6669
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
