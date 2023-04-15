kind: manual

sources:
- kind: remote
  url: https://github.com/Schneegans/Fly-Pie/releases/download/v19/flypie@schneegans.github.com.zip
  ref: 298bbb6e9cbbcddf0fa45261d8cfd1dec1ee9db03d15993f64ea1141a3bbc937
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- freedesktop-sdk.bst:components/unzip.bst

environment:
  UUID: flypie@schneegans.github.com
config:
  install-commands:
  - mkdir -p %{install-root}/usr/share/gnome-shell/extensions/${UUID}/
  - unzip flypie@schneegans.github.com.zip -d %{install-root}/usr/share/gnome-shell/extensions/${UUID}/

