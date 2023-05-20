kind: import

sources:
- kind: git_tag
  url: github:zsh-users/zsh-autosuggestions.git
  track: master

  ref: v0.7.0-0-ga411ef3e0992d4839f0732ebeb9823024afaaaa8
config:
  source: /
  target: "%{datadir}/ohmyzsh/custom/plugins/zsh-autosuggestions"
