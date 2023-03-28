kind: manual

sources:
- kind: git_tag
  url: github:googlefonts/noto-cjk
  track: main

  ref: Sans2.004-16-gfcf3fdab7d4f10dde80f56526bd4376d21dacf0c
build-depends:
- freedesktop-sdk.bst:bootstrap-import.bst
config:
  install-commands:
  - install -Dm644 */Variable/OTC/*.otf.ttc -t %{install-root}%{datadir}/fonts/noto-cjk/
