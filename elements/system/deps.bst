kind: stack

(?):
  - variant == "desktop":
      depends:
        - variants/desktop.bst

  - variant == "workstation" or variant == "experimental":
      depends:
        - variants/workstation.bst