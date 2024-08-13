include-root: /sysroot
force-rebuild: false
include-upon: platform.yml
strip: false
type: extension
extra-commands: ""
initial-commands: |-
  [ -d %{include-root}/%{sysconfdir} ] && mv %{include-root}/%{sysconfdir} %{include-root}/%{prefix}/
  %{extra-commands}

ostree-branch: x86_64/extension/%{id}/%{channel}

merge: [channel.yml, elements/include/ostree.inc]
