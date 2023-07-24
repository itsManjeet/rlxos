kind: stack

depends:
- components/libostree.bst
- components/libisoburn.bst
- freedesktop-sdk.bst:integration/mtab.bst
- freedesktop-sdk.bst:components/genimage.bst
- freedesktop-sdk.bst:vm/prepare-image.bst
- freedesktop-sdk.bst:snap-images/squashfs-tools.bst
