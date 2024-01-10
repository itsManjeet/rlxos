depends:
  - components/xfce4/xfce4-panel.yml

build-depends:
  - components/intltool.yml

configure: >-
  --disable-debug

sources:
  - https://archive.xfce.org/src/panel-plugins/%{id}/%{version:2}/%{id}-%{version}.tar.bz2
