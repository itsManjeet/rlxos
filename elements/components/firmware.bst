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
  ref: 20230404-38-gfab149657d8d029c06179dd006b59b2f3594f916
- kind: patch
  path: patches/firmware/compress.patch
