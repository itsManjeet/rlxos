kind: stack

(?):
  - variant == "desktop":
      depends:
        - variants/desktop.bst

  - variant == "workstation":
      depends:
        - variants/workstation.bst