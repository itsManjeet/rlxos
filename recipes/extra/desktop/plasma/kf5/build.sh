#!/bin/sh

BUILD_ORDER='attica
extra-cmake-modules
kapidox
karchive
kcodecs
kconfig
kcoreaddons
kdbusaddons
kdnssd
kguiaddons
ki18n
kidletime
kimageformats
kitemmodels
kitemviews
kplotting
kwidgetsaddons
kwindowsystem
networkmanager-qt
solid
sonnet
threadweaver
kauth
kcompletion
kcrash
kdoctools
kpty
kunitconversion
kconfigwidgets
kservice
kglobalaccel
kpackage
kdesu
kemoticons
kiconthemes
kjobwidgets
knotifications
ktextwidgets
kxmlgui
kbookmarks
kwallet
kded
kio
kdeclarative
kcmutils
kirigami2
syndication
knewstuff
frameworkintegration
kinit
kparts
kactivities
syntax-highlighting
ktexteditor
kdesignerplugin
kwayland
plasma-framework
kpeople
kxmlrpcclient
bluez-qt
kfilemetadata
baloo
kactivities-stats
krunner
prison
qqc2-desktop-style
kjs
kdelibs4support
khtml
kjsembed
kmediaplayer
kross
kholidays
purpose
kcalendarcore
kcontacts
kquickcharts
knotifyconfig
kdav'

for i in ${BUILD_ORDER} ; do
    echo "building ${i}"
    pkgupd build build.recipe=/var/cache/pkgupd/recipes/extra/desktop/plasma/kf5/${i}/${i}.yml | tee /logs/${i}.log
    if [[ $? != 0 ]] ; then
        exit 1
    fi
done

echo "done"