kind: compose

build-depends:
  - system/deps.bst
  - system/manifest.bst

config:
  exclude:
    - debug
  (?):
    - variant == "desktop":
        exclude:
          (>):
            - devel
