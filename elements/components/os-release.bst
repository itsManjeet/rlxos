kind: manual

depends:
- freedesktop-sdk.bst:bootstrap-import.bst

config:
  install-commands:
    - mkdir -p %{install-root}%{sysconfdir} %{install-root}/%{indep-libdir}
    - echo "RLXOS %{variant} \n \l" > %{install-root}%{sysconfdir}/issue
    - echo "RLXOS %{variant} %h" > %{install-root}%{sysconfdir}/issue.net
    - |
      cat > %{install-root}/%{indep-libdir}/os-release << "EOF"
      NAME="RLXOS"
      VERSION="%{variant}"
      VERSION_ID="%{variant}"
      ID=rlxos
      PRETTY_NAME="rlxos %{variant}"
      BUG_REPORT_URL="https://github.com/itsManjeet/rlxos/issues"
      HOME_URL="https://rlxos.dev"
      EOF
      
    - ln -s "$(realpath --relative-to="%{install-root}%{sysconfdir}" %{install-root}%{indep-libdir}/os-release)" %{install-root}%{sysconfdir}/os-release
