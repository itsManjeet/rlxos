merge: [version.yml, elements/include/ostree.inc]
variables:
  force-rebuild: true
  include-depends: false
  include-root: /sysroot
  strip: false
  extra-commands: ""
  initial-commands: |-
    [ -d %{include-root}/%{sysconfdir} ] && mv %{include-root}/%{sysconfdir} %{include-root}/%{prefix}/
    %{extra-commands}

  ostree-branch: x86_64/extension/%{id}/%{version}