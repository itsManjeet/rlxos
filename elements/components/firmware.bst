kind: manual

depends:
- freedesktop-sdk.bst:bootstrap-import.bst
- components/sof-firmware.bst
build-depends:
- freedesktop-sdk.bst:components/python3.bst

config:
  install-commands:
  - make DESTDIR="%{install-root}" FIRMWAREDIR="%{indep-libdir}/firmware" installcompress

sources:
- kind: git_tag
  url: kernel:linux/kernel/git/firmware/linux-firmware.git
  track: main
  ref: 20230117-3-gbb2d42dceff755623d6d59a32a743ccf87cbb6b9
- kind: patch
  path: patches/firmware/compress.patch
