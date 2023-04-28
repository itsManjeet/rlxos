kind: make

sources:
- kind: tar
  url: thekelleys:dnsmasq/dnsmasq-2.89.tar.xz

  ref: 02bd230346cf0b9d5909f5e151df168b2707103785eb616b56685855adebb609
depends:
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  make-install: make -j1 BINDIR=%{sbindir} PREFIX="%{prefix}" DESTDIR="%{install-root}"
    install
