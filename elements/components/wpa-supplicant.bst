kind: manual

sources:
  - kind: local
    path: files/wpa-supplicant/wpa-supplicant.preset

build-depends:
  - freedesktop-sdk.bst:components/pkg-config.bst
  - freedesktop-sdk.bst:components/systemd.bst

runtime-depends:
  - freedesktop-sdk.bst:components/wpa-supplicant.bst

config:
  install-commands:
    - |
      systemdsystempresetdir="$(pkg-config --variable systemdsystempresetdir systemd)"
      install -Dm644 -t "%{install-root}${systemdsystempresetdir}" wpa-supplicant.preset
