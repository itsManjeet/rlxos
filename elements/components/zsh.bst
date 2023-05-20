kind: autotools

sources:
- kind: tar
  url: https://www.zsh.org/pub/zsh-5.9.tar.xz

  ref: 9b8d1ecedd5b5e81fbf1918e876752a7dd948e05c1a0dba10ab863842d45acd5
- kind: patch
  path: patches/zsh/0001-50629-do-not-use-egrep-in-tests.patch


depends:
- freedesktop-sdk.bst:bootstrap-import.bst
- freedesktop-sdk.bst:components/gdbm.bst
- freedesktop-sdk.bst:components/libcap.bst

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

runtime-depends:
- components/ohmyzsh.bst

variables:
  conf-local: >-
    --enable-zsh-secure-free
    --enable-cap
    --enable-gdbm
    --with-tcsetpgrp
    --enable-zshrc=/etc/zshrc

config:
  install-commands:
    (>):
    - rm %{install-root}/usr/bin/zsh-5.9
    - mkdir -p %{install-root}%{sysconfdir}
    - echo "emulate sh -c 'source %{sysconfdir}/profile'" > %{install-root}%{sysconfdir}/zprofile

public:
  bst:
    integration-commands:
    - echo /bin/zsh >> /etc/shells
