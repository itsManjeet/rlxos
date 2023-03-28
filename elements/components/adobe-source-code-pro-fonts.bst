kind: manual

depends:
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  fontdir: '%{datadir}/fonts/adobe-source-code-pro-fonts'
  confdir: '%{sysconfdir}/fonts'

config:
  install-commands:
  - |
    install -d -m0755 "%{install-root}%{confdir}/conf.avail" "%{install-root}%{confdir}/conf.d" "%{install-root}%{fontdir}"
    install -p -m0644 OTF/*.otf "%{install-root}%{fontdir}/"
    install -p -m0644 "config/adobe-source-code-pro.conf" "%{install-root}%{confdir}/conf.avail/"
    ln -s "../conf.avail/61-adobe-source-code-pro.conf" "%{install-root}%{confdir}/conf.d/"

sources:
- kind: tar
  url: github_files:adobe-fonts/source-code-pro/archive/2.010R-ro/1.030R-it.tar.gz
  ref: 3ee5a0d04e6586f12de038cb33ec963f137bbc4907ae1e10a6333478a2b884f8
- kind: local
  path: files/font-conf/adobe-source-code-pro.conf
  directory: config
