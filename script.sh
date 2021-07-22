_list='iceauth-1.0.8.tar.bz2
luit-1.1.1.tar.bz2
mkfontscale-1.2.1.tar.bz2
sessreg-1.1.2.tar.bz2
setxkbmap-1.3.2.tar.bz2
smproxy-1.0.6.tar.bz2
x11perf-1.6.1.tar.bz2
xauth-1.1.tar.bz2
xbacklight-1.2.3.tar.bz2
xcmsdb-1.0.5.tar.bz2
xcursorgen-1.0.7.tar.bz2
xdpyinfo-1.3.2.tar.bz2
xdriinfo-1.0.6.tar.bz2
xev-1.2.4.tar.bz2
xgamma-1.0.6.tar.bz2
xhost-1.0.8.tar.bz2
xinput-1.6.3.tar.bz2
xkbcomp-1.4.5.tar.bz2
xkbevd-1.1.4.tar.bz2
xkbutils-1.0.4.tar.bz2
xkill-1.0.5.tar.bz2
xlsatoms-1.1.3.tar.bz2
xlsclients-1.1.4.tar.bz2
xmessage-1.0.5.tar.bz2
xmodmap-1.0.10.tar.bz2
xpr-1.0.5.tar.bz2
xprop-1.2.5.tar.bz2
xrandr-1.5.1.tar.xz
xrdb-1.2.0.tar.bz2
xrefresh-1.0.6.tar.bz2
xset-1.2.4.tar.bz2
xsetroot-1.1.2.tar.bz2
xvinfo-1.1.4.tar.bz2
xwd-1.0.7.tar.bz2
xwininfo-1.1.5.tar.bz2
xwud-1.0.5.tar.bz2'

echo "
id: xorg-apps
version: 7
about: |
  Xorg apps

depends:
  runtime:
    - libpng
    - mesa
    - xbitmaps
    - xcb-util
    - pam

packages:" > xorg-apps.yml

for i in ${_list} ; do
  echo "
  - id: $(echo $i | cut -d '-' -f1)
    dir: $(echo $i | sed 's|.tar.bz2||g')
    sources:
      - https://www.x.org/pub/individual/app/${i}" >> xorg-apps.yml

done
