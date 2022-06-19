#!/bin/bash

for i in extra/extra-cmake-modules \
multimedia/phonon \
extra/polkit-qt \
libraries/libdbusmenu-qt \
extra/plasma-wayland-protocols \
kf5/attica \
kf5/kapidox \
kf5/karchive \
kf5/kcodecs \
kf5/kconfig \
kf5/kcoreaddons \
kf5/kdbusaddons \
kf5/kdnssd \
kf5/kguiaddons \
kf5/ki18n \
kf5/kidletime \
kf5/kimageformats \
kf5/kitemmodels \
kf5/kitemviews \
kf5/kplotting \
kf5/kwidgetsaddons \
kf5/kwindowsystem \
kf5/networkmanager-qt \
kf5/solid \
kf5/sonnet \
kf5/threadweaver \
kf5/kauth \
kf5/kcompletion \
kf5/kcrash \
kf5/kdoctools \
kf5/kpty \
kf5/kunitconversion \
kf5/kconfigwidgets \
kf5/kservice \
kf5/kglobalaccel \
kf5/kpackage \
kf5/kdesu \
kf5/kemoticons \
kf5/kiconthemes \
kf5/kjobwidgets \
kf5/knotifications \
kf5/ktextwidgets \
kf5/kxmlgui \
kf5/kbookmarks \
kf5/kwallet \
kf5/kded \
kf5/kio \
kf5/kdeclarative \
kf5/kcmutils \
kf5/kirigami2 \
kf5/syndication \
kf5/knewstuff \
kf5/frameworkintegration \
kf5/kinit \
kf5/kparts \
kf5/kactivities \
kf5/kdewebkit \
kf5/syntax-highlighting \
kf5/ktexteditor \
kf5/kdesignerplugin \
kf5/kwayland \
kf5/plasma-framework \
kf5/kpeople \
kf5/kxmlrpcclient \
kf5/bluez-qt \
kf5/kfilemetadata \
kf5/baloo \
kf5/kactivities-stats \
kf5/krunner \
kf5/prison \
kf5/qqc2-desktop-style \
kf5/kjs \
kf5/kdelibs4support \
kf5/khtml \
kf5/kjsembed \
kf5/kmediaplayer \
kf5/kross \
kf5/kholidays \
kf5/purpose \
kf5/kcalendarcore \
kf5/kcontacts \
kf5/kquickcharts \
kf5/knotifyconfig \
kf5/kdav \
modules/kdecoration \
modules/libkscreen \
modules/libksysguard \
modules/breeze \
modules/breeze-gtk \
modules/layer-shell-qt \
modules/kscreenlocker \
modules/oxygen \
modules/kinfocenter \
modules/kwayland-server \
modules/kwin \
modules/plasma-workspace \
modules/plasma-disks \
modules/bluedevil \
modules/kde-gtk-config \
modules/khotkeys \
modules/kmenuedit \
modules/kscreen \
modules/kwallet-pam \
modules/kwayland-integration \
modules/kwrited \
modules/milou \
modules/plasma-nm \
modules/plasma-pa \
modules/plasma-workspace-wallpapers \
modules/polkit-kde-agent-1 \
modules/powerdevil \
modules/plasma-desktop \
modules/kdeplasma-addons \
modules/kgamma5 \
modules/ksshaskpass \
modules/sddm-kcm \
modules/discover \
modules/kactivitymanagerd \
modules/plasma-integration \
modules/plasma-tests \
modules/xdg-desktop-portal-kde \
modules/drkonqi \
modules/plasma-vault \
modules/plasma-browser-integration \
modules/kde-cli-tools \
modules/systemsettings \
modules/plasma-thunderbolt \
modules/plasma-firewall \
modules/plasma-systemmonitor \
modules/qqc2-breeze-style \
modules/ksystemstats ; do

pkgid=$(basename ${i})
echo "building ${i}"

./scripts/bootstrap.sh --build-package recipes/extra/desktop/plasma/${i}/${pkgid}.yml
if [[ $? != 0 ]] ; then
    echo "Failed to build ${i}"
    exit 1
fi
done