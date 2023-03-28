kind: manual

build-depends:
- freedesktop-sdk.bst:bootstrap-import.bst
sources:
- kind: tar
  url: https://www.alsa-project.org/files/pub/lib/alsa-ucm-conf-1.2.8.tar.bz2

  ref: fee4a737830fd25f969d83da46a2b231beb086efd966fcc07d225e7823260ae8
config:
  configure-commands:
  - install -vdm 755 %{install-root}%{datadir}/alsa/

  install-commands:
  - cp -av ucm2 %{install-root}%{datadir}/alsa/
