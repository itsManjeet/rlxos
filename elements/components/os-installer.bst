kind: cmake

sources:
- kind: git_tag
  url: github:itsmanjeet/initial-setup.git
  track: main

  ref: f7073c684bd2e863419f764e8a3de4394d42e94d
depends:
- freedesktop-sdk.bst:bootstrap-import.bst
- components/gtkmm-3.bst

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst

runtime-depends:
- components/gnome-session.bst

config:
  configure-commands:
    (>):
    - sed -i 's#"live"#"rlxos.live=1"#g' src/Application.cxx
  install-commands:
  - install -D -m 0755 %{build-dir}/src/initial_setup %{install-root}/%{bindir}/os-installer