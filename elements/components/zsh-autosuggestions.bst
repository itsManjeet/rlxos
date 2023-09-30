kind: import

sources:
- kind: git_tag
  url: github:zsh-users/zsh-autosuggestions.git
  track: master

  ref: v0.7.0-12-gc3d4e576c9c86eac62884bd47c01f6faed043fc5
config:
  source: /
  target: "%{datadir}/ohmyzsh/custom/plugins/zsh-autosuggestions"
