kind: manual

sources:
- kind: remote
  url: https://github.com/Schneegans/Fly-Pie/releases/download/v17/flypie@schneegans.github.com.zip
  ref: a0a1ff80a5396530d285f453095437e53ba925e7c7233d71ce9303ad0609e172
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- freedesktop-sdk.bst:components/unzip.bst

environment:
  UUID: flypie@schneegans.github.com
config:
  install-commands:
  - mkdir -p %{install-root}/usr/share/gnome-shell/extensions/${UUID}/
  - unzip flypie@schneegans.github.com.zip -d %{install-root}/usr/share/gnome-shell/extensions/${UUID}/

