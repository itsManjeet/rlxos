kind: manual

config:
  configure-commands:
  - |
    sed -i '2i import sys' main.py
    sed -i '3i sys.path.append("%{datadir}/waydroid-script")' main.py

  install-commands:
  - |
    install -vDm755 main.py  %{install-root}%{bindir}/waydroid-script
    mkdir -p %{install-root}%{datadir}/waydroid-script/
    cp -r stuff tools bin %{install-root}%{datadir}/waydroid-script/

  strip-commands:
  - true

build-depends:
- freedesktop-sdk.bst:components/python3-pip.bst
depends:
- components/python3-tqdm.bst
- components/python3-inquirerpy.bst
- freedesktop-sdk.bst:components/python3-requests.bst
- freedesktop-sdk.bst:components/python3.bst

sources:
- kind: git_tag
  url: github:casualsnek/waydroid_script.git
  track: main
  ref: 59547e774335c12f08d20b65490bb1be840d7f87
