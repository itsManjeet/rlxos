_list='attica-5.83.0.tar.xz
extra-cmake-modules-5.83.0.tar.xz
kapidox-5.83.0.tar.xz
karchive-5.83.0.tar.xz
kcodecs-5.83.0.tar.xz
kconfig-5.83.0.tar.xz
kcoreaddons-5.83.0.tar.xz
kdbusaddons-5.83.0.tar.xz
kdnssd-5.83.0.tar.xz
kguiaddons-5.83.0.tar.xz
ki18n-5.83.0.tar.xz
kidletime-5.83.0.tar.xz
kimageformats-5.83.0.tar.xz
kitemmodels-5.83.0.tar.xz
kitemviews-5.83.0.tar.xz
kplotting-5.83.0.tar.xz
kwidgetsaddons-5.83.0.tar.xz
kwindowsystem-5.83.0.tar.xz
networkmanager-qt-5.83.0.tar.xz
solid-5.83.0.tar.xz
sonnet-5.83.0.tar.xz
threadweaver-5.83.0.tar.xz
kauth-5.83.0.tar.xz
kcompletion-5.83.0.tar.xz
kcrash-5.83.0.tar.xz
kdoctools-5.83.0.tar.xz
kpty-5.83.0.tar.xz
kunitconversion-5.83.0.tar.xz
kconfigwidgets-5.83.0.tar.xz
kservice-5.83.0.tar.xz
kglobalaccel-5.83.0.tar.xz
kpackage-5.83.0.tar.xz
kdesu-5.83.0.tar.xz
kemoticons-5.83.0.tar.xz
kiconthemes-5.83.0.tar.xz
kjobwidgets-5.83.0.tar.xz
knotifications-5.83.0.tar.xz
ktextwidgets-5.83.0.tar.xz
kxmlgui-5.83.0.tar.xz
kbookmarks-5.83.0.tar.xz
kwallet-5.83.0.tar.xz
kded-5.83.0.tar.xz
kio-5.83.0.tar.xz
kdeclarative-5.83.0.tar.xz
kcmutils-5.83.0.tar.xz
kirigami2-5.83.0.tar.xz
knewstuff-5.83.0.tar.xz
frameworkintegration-5.83.0.tar.xz
kinit-5.83.0.tar.xz
kparts-5.83.0.tar.xz
kactivities-5.83.0.tar.xz
kdewebkit-5.83.0.tar.xz
syntax-highlighting-5.83.0.tar.xz
ktexteditor-5.83.0.tar.xz
kdesignerplugin-5.83.0.tar.xz
kwayland-5.83.0.tar.xz
plasma-framework-5.83.0.tar.xz
modemmanager-qt-5.83.0.tar.xz
kpeople-5.83.0.tar.xz
kxmlrpcclient-5.83.0.tar.xz
bluez-qt-5.83.0.tar.xz
kfilemetadata-5.83.0.tar.xz
baloo-5.83.0.tar.xz
breeze-icons-5.83.0.tar.xz
oxygen-icons5-5.83.0.tar.xz
kactivities-stats-5.83.0.tar.xz
krunner-5.83.0.tar.xz
prison-5.83.0.tar.xz
qqc2-desktop-style-5.83.0.tar.xz
kjs-5.83.0.tar.xz
kdelibs4support-5.83.0.tar.xz
khtml-5.83.0.tar.xz
kjsembed-5.83.0.tar.xz
kmediaplayer-5.83.0.tar.xz
kross-5.83.0.tar.xz
kholidays-5.83.0.tar.xz
purpose-5.83.0.tar.xz
kcalendarcore-5.83.0.tar.xz
kcontacts-5.83.0.tar.xz
kquickcharts-5.83.0.tar.xz
knotifyconfig-5.83.0.tar.xz
syndication-5.83.0.tar.xz'

echo "id: kf5
version: 5.83
about: |
  A collection of libraries based on top of Qt5 and QML derived from the monolithic KDE 4 libraries

clean: true
split: false

# TODO: {avahi,bluez}
depends:
  runtime:
    - giflib
    - libepoxy
    - libgcrypt
    - libical
    - libjpeg-turbo
    - libpng
    - networkmanager
    - libxslt
    - lmdb
    - qrencode
    - phonon
    - plasma-wayland-protocols
    - shared-mime-info
    - perl-uri
    - polkit-qt
    
  buildtime:
    - extra-cmake-modules
    - boost
    - docbook-xml
    - docbook-xsl

packages:" > plasma.yml

for i in ${_list} ; do
  echo "
  - id: $(echo $i | cut -d '-' -f1)
    dir: $(echo $i | sed 's|.tar.bz2||g' | sed 's|.tar.xz||g' | sed 's|.tar.gz||g')
    sources:
      - https://download.kde.org/stable/frameworks/5.83/${i}
    
    flags:
      - id: configure
        only: true
        value: >
          -DCMAKE_INSTALL_PREFIX=/usr
          -DCMAKE_PREFIX_PATH=/usr
          -DCMAKE_BUILD_TYPE=Release
          -DBUILD_TESTING=OFF
          -Wno-dev .." >> plasma.yml

done
