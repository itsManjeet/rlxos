kind: manual

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
- components/gnome-shell.bst

environment:
  UUID: widgets@aylur
config:
  install-commands:
  - mkdir -pv %{install-root}/usr/share/gnome-shell/extensions/
  - cp -av ${UUID} %{install-root}/usr/share/gnome-shell/extensions/
  - glib-compile-schemas %{install-root}%{datadir}/gnome-shell/extensions/${UUID}/schemas
sources:
- kind: git_tag
  url: github:Aylur/gnome-extensions.git
  track: main

  ref: 60e66a7d801aa238c64165e4d28108e793fdba98
- kind: patch
  path: patches/gnome-shell-extensions/aylur-widgets/configurations.patch
