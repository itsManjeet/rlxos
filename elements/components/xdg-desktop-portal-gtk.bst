kind: autotools

sources:
- kind: tar
  url: github_files:flatpak/xdg-desktop-portal-gtk/releases/download/1.10.0/xdg-desktop-portal-gtk-1.10.0.tar.xz

  ref: c809757bb5cb5d067a99be373b36a05578e0f710c1d69aad7222e98d4db38b5a
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- components/gtk+-3.bst
- components/xdg-desktop-portal.bst

variables:
  conf-local: >-
    --disable-appchooser
    --disable-background
    --disable-lockdown
    --disable-screencast
    --disable-screenshot
    --disable-settings
    --disable-wallpaper
