kind: autotools

sources:
- kind: tar
  url: gnome_downloads:NetworkManager-openconnect/1.2/NetworkManager-openconnect-1.2.6.tar.xz

  ref: 95109803596a9782680a5dca3b51c4ad8ff7e126169d5431278cab694112975a
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
- components/intltool.bst

depends:
- components/gcr-3.bst
- components/gtk+-3.bst
- components/networkmanager.bst
- components/openconnect.bst

