kind: manual

sources:
- kind: git_tag
  url: github:ohmyzsh/ohmyzsh.git
  track: master

  ref: 27402e2603b9354f419af3695bad8ff17ed33bac
- kind: local
  path: files/zsh/

depends:
- components/zsh-autosuggestions.bst

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

config:
  configure-commands:
  - sed -i 's#__DATADIR__#%{datadir}#g' zshrc

  install-commands:
  - install -Dm644 -t %{install-root}%{sysconfdir} zshrc
  - mkdir -p %{install-root}%{datadir}/ohmyzsh
  - cp -r * %{install-root}%{datadir}/ohmyzsh/
