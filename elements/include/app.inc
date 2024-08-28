extra-commands: ""

script: |-
    ( cd /rlxos; go build -o %{install-root}/%{bindir}/%{id} rlxos/apps/%{id} )
    %{extra-commands}

post-script: |-
    rm /go -rf

build-depends:
    - components/go.yml

depends:
    - components/gtk4.yml