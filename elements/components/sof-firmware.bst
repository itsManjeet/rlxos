kind: manual

sources:
- kind: tar
  url: https://github.com/thesofproject/sof-bin/releases/download/v2.2.2/sof-bin-v2.2.2.tar.gz

  ref: 00f38f29e3d71e9e4a85536a913355ec5a78ab629ecd4df355b20f150f57fcc0
build-depends:
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  fwdir: '%{install-root}/%{indep-libdir}/firmware/intel'
config:
  install-commands:
  - mkdir -p %{fwdir}
  - cp -at %{fwdir} sof-v2.2.2/
  - ln -sr %{fwdir}/{sof-v2.2.2,sof}
  - cp -at %{fwdir} sof-tplg-v2.2.2
  - ln -sr %{fwdir}/{sof-tplg-v2.2.2,sof-tplg}
