kind: make

sources:
- kind: tar
  url: thekelleys:dnsmasq/dnsmasq-2.88.tar.xz

  ref: 23544deda10340c053bea6f15a93fed6ea7f5aaa85316bfc671ffa6d22fbc1b3
depends:
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  make-install: make -j1 BINDIR=%{sbindir} PREFIX="%{prefix}" DESTDIR="%{install-root}"
    install
