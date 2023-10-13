kind: stack

(?):
  - variant == "desktop":
      depends:
        - collections/desktop.bst

  - variant == "workstation" or variant == "experimental":
      depends:
        - collections/workstation.bst