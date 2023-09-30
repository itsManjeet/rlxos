kind: autotools

sources:
- kind: tar
  url: 
    github_files:flatpak/xdg-desktop-portal-gtk/releases/download/1.14.1/xdg-desktop-portal-gtk-1.14.1.tar.xz

  ref: 3ee2a992187eabb237a76170a7dead2a3bcea2edbf59344647cc0d1c640a5700
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- components/gtk+-3.bst
- freedesktop-sdk.bst:components/xdg-desktop-portal.bst

variables:
  conf-local: >-
    --disable-appchooser
    --disable-background
    --disable-lockdown
    --disable-screencast
    --disable-screenshot
    --disable-settings
    --disable-wallpaper
