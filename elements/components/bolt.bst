kind: cmake

sources:
- kind: git_tag
  track: master
  url: github:itsmanjeet/bolt.git

  ref: 0.0.1-3-g75b416663d5af14cd2a7b6962766121c6537f37c

- kind: local
  path: files/bolt/bolt.json

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst

depends:
- freedesktop-sdk.bst:bootstrap-import.bst
- components/vosk-api.bst
- components/pipewire.bst
- components/espeak-ng.bst

config:
   install-commands:
     (>):
      - install -Dm0644 -t %{install-root}%{sysconfdir} bolt.json
