kind: cmake

sources:
- kind: git_tag
  track: master
  url: github:itsmanjeet/bolt.git

  ref: 0.0.1-4-g77d68cd5707e0bf8545e4ffefa660a3631141c8a

- kind: local
  path: files/bolt/bolt.json

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst

depends:
- freedesktop-sdk.bst:bootstrap-import.bst
- components/vosk-api.bst
- components/pipewire.bst
- components/espeak-ng.bst
- freedesktop-sdk.bst:components/curl.bst

config:
  install-commands:
    (>):
    - install -Dm0644 -t %{install-root}%{sysconfdir} bolt.json
