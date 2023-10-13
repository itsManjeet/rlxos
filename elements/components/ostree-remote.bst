kind: manual
sources:
  - kind: local
    path: files/ostree/ostree.conf
  - kind: local
    path: files/ostree/rlxos.conf.in
  - kind: local
    path: files/rlxos.gpg

build-depends:
  - freedesktop-sdk.bst:bootstrap-import.bst
  - freedesktop-sdk.bst:components/m4.bst

runtime-depends:
  - freedesktop-sdk.bst:components/systemd.bst
  - freedesktop-sdk.bst:components/ostree.bst

config:
  install-commands:
    - mkdir -p %{install-root}/{boot,efi,etc,mnt,run,opt,sys,tmp,dev,proc,home,root,sysroot}
    - ln -sv sysroot/ostree %{install-root}/ostree
    - install -Dm644 -t "%{install-root}/usr/lib/systemd/system" home.mount root.mount
    - mkdir -p %{install-root}/etc/ostree/remotes.d
    - m4 -DOSTREE_REMOTE_URL="%{ostree-remote-url}" %{build-root}/rlxos.conf.in > %{install-root}/etc/ostree/remotes.d/rlxos.conf
    - install -Dm644 %{build-root}/rlxos.gpg -t %{install-root}/etc/pki/ostree/
    - install -Dm644 -t %{install-root}/usr/lib/tmpfiles.d %{build-root}/ostree.conf
