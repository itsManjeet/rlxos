kind: manual

sources:
- kind: git_tag
  url: github:ohmyzsh/ohmyzsh.git
  track: master

  ref: 46c70406dd0b26bbd61210873ad6c86d9e8ee5da
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
