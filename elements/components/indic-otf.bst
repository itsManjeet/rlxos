kind: manual

build-depends:
- freedesktop-sdk.bst:bootstrap-import.bst

config:
  install-commands:
  - install -Dm644 -t %{install-root}/%{datadir}/fonts/TTF OpenType/*.ttf


sources:
- kind: tar
  url: https://www.indlinux.org/downloads/files/indic-otf-0.2.tar.gz
  ref: 6459a0d496a701fdde785eccfb2a21ad761251bd332e03521657443339215e72
