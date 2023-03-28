kind: cmake

sources:
- kind: git_tag
  track: master
  url: github:itsmanjeet/bolt.git

  ref: 0.0.1-2-g1e03d8c91736c1b31c73a86c9f0c24cc6852dba4

- kind: local
  path: files/bolt/command_not_found.fish

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst

depends:
- freedesktop-sdk.bst:bootstrap-import.bst
- components/vosk-api.bst

# config:
#   install-commands:
#     (>):
#     - install -Dm0644 -t %{install-root}%{sysconfdir}/fish/conf.d command_not_found.fish
