kind: manual

sources:
- kind: git_tag
  url: github:googlefonts/noto-cjk
  track: main

  ref: Serif2.002-1-g727f898acdf7b100d308af8edf63c3953b626a1b

- kind: local
  path: files/font-conf/noto-cjk.conf
  directory: config

build-depends:
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  fontdir: '%{datadir}/fonts/noto-cjk'
  confdir: '%{sysconfdir}/fonts'

config:
  install-commands:
  - |
    install -d -m0755 "%{install-root}%{confdir}/conf.avail" "%{install-root}%{confdir}/conf.d" "%{install-root}%{fontdir}"
    install -p -m0644 */OTC/*.ttc "%{install-root}%{fontdir}/"
    install -p -m0644 "config/noto-cjk.conf" "%{install-root}%{confdir}/conf.avail/"
    ln -s "../conf.avail/70-noto-cjk.conf" "%{install-root}%{confdir}/conf.d/"

