kind: meson

sources:
- kind: tar
  url: github_files:fwupd/fwupd-efi/archive/refs/tags/1.3/1.3.tar.gz
  ref: 0e76057c178e221f63eaf9142fa1d06780a8eb3df7cf0c11f92660138dec5c83

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- freedesktop-sdk.bst:components/gnu-efi.bst
- freedesktop-sdk.bst:bootstrap-import.bst
