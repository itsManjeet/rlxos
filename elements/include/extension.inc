force-rebuild: true
include-root: /sysroot
include-upon: system/deps.yml
strip: false
type: extension
extra-commands: ""
initial-commands: |-
  [ -d %{include-root}/%{sysconfdir} ] && mv %{include-root}/%{sysconfdir} %{include-root}/%{prefix}/
  %{extra-commands}

ostree-branch: x86_64/extension/%{id}/%{channel}

merge: [version.yml, elements/include/ostree.inc]