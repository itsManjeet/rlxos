kind: cmake

sources:
- kind: git_tag
  track: master
  url: github:itsmanjeet/bolt.git

  ref: 0.0.1-5-g8d1d3a9963d6eb33667c1052020f8b02004e373b

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
