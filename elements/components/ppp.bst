kind: autotools
sources:
- kind: tar
  url: samba:ppp/ppp-2.4.9.tar.gz
  ref: f938b35eccde533ea800b15a7445b2f1137da7f88e32a16898d02dee8adc058d
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- components/libpcap.bst
- freedesktop-sdk.bst:bootstrap-import.bst
- freedesktop-sdk.bst:components/openssl.bst
variables:
  # not a real autotools project
  autogen: ''
  make-install: make -j1 INSTROOT="%{install-root}" BINDIR="%{install-root}%{bindir}"
    install
