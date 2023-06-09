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
  ref: 20230515-50-gfc90c59beebd551dde5fe5eb3e76d36651ba08fb
- kind: patch
  path: patches/firmware/compress.patch
