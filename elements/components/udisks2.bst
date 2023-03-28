kind: autotools

sources:
- kind: tar
  url: github_files:storaged-project/udisks/releases/download/udisks-2.9.2/udisks-2.9.2.tar.bz2

  ref: bda6f9d7edc632c57e55862731a8ffeff2413fa4346708a22bf31ed72b0fe058
build-depends:
- components/gtk-doc.bst
- freedesktop-sdk.bst:components/docbook-xsl.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

runtime-depends:
- freedesktop-sdk.bst:components/btrfs-progs.bst
- freedesktop-sdk.bst:components/dosfstools.bst
- freedesktop-sdk.bst:components/e2fsprogs.bst
- freedesktop-sdk.bst:components/f2fs-tools.bst
- freedesktop-sdk.bst:components/parted.bst
- freedesktop-sdk.bst:components/util-linux.bst

depends:
- components/gobject-introspection.bst
- freedesktop-sdk.bst:components/libatasmart.bst
- freedesktop-sdk.bst:components/libblockdev.bst
- freedesktop-sdk.bst:components/libgudev.bst
- freedesktop-sdk.bst:components/polkit.bst
- freedesktop-sdk.bst:bootstrap-import.bst
