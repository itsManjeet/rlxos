script: |-
    ( cd /rlxos; go build -o %{install-root}/%{bindir}/%{id} rlxos/apps/%{id} )

build-depends:
    - components/go.yml