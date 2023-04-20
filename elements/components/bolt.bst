kind: cmake

sources:
- kind: git_tag
  track: master
  url: github:itsmanjeet/bolt.git

  ref: 0.0.1-9-g69ad2afc860f59ad02c113832c049e4b20c5a1a6

- kind: local
  path: files/bolt/bolt.json

- kind: patch
  path: patches/bolt/0001-FIXED-scoring.patch

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst

depends:
- freedesktop-sdk.bst:bootstrap-import.bst
- components/vosk-api.bst
- components/pipewire.bst
- components/espeak-ng.bst
- freedesktop-sdk.bst:components/curl.bst

config:
  configure-commands:
    (>):
    - ./scripts/merge-training.sh

  build-commands:
    (>):
    - _builddir/bolt -config data/config.json -train training.txt data/model.json

  install-commands:
    (>):
    - install -Dm0644 -t %{install-root}%{sysconfdir} bolt.json
