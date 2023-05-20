kind: manual

sources:
- kind: git_tag
  url: github:ohmyzsh/ohmyzsh.git
  track: master

  ref: 7a030f6bd6c15259052c7007020cf3ecf8a3f299
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
