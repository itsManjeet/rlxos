kind: autotools

sources:
- kind: tar
  url: github_files:lathiat/nss-mdns/releases/download/v0.14.1/nss-mdns-0.14.1.tar.gz

  ref: a2094101b735cade45048764ea594bdae2bfa9399837f3c852a5b264416e9c8c
runtime-depends:
- freedesktop-sdk.bst:components/avahi.bst

depends:
- freedesktop-sdk.bst:bootstrap-import.bst
