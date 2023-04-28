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

  ref: 66a789773f4c73ad4df2fddc37b1358de11e64e3
- kind: patch
  path: patches/gnome-shell-extensions/aylur-widgets/configurations.patch
