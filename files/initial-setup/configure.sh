#! /bin/bash

# OSI_USER_NAME          : User's name. Not ASCII-fied
# OSI_USER_AUTOLOGIN     : Whether to autologin the user
# OSI_USER_PASSWORD      : User's password. Can be empty if autologin is set.
# OSI_FORMATS            : Locale of formats to be used
# OSI_TIMEZONE           : Timezone to be used
# OSI_ADDITIONAL_SOFTWARE: Space-separated list of additional packages to install

# sanity check that all variables were set
if [ -z ${OSI_LOCALE+x} ] || \
   [ -z ${OSI_USER_NAME+x} ] || \
   [ -z ${OSI_USER_AUTOLOGIN+x} ] || \
   [ -z ${OSI_USER_PASSWORD+x} ] || \
   [ -z ${OSI_FORMATS+x} ] || \
   [ -z ${OSI_TIMEZONE+x} ] || \
   [ -z ${OSI_ADDITIONAL_SOFTWARE+x} ]
then
    echo "Configure script called without all environment variables set!"
    exit 1
fi

echo 'Configuration started.'
echo ''
echo 'Variables set to:'
echo 'OSI_LOCALE               ' $OSI_LOCALE
echo 'OSI_USER_NAME            ' $OSI_USER_NAME
echo 'OSI_USER_AUTOLOGIN       ' $OSI_USER_AUTOLOGIN
echo 'OSI_FORMATS              ' $OSI_FORMATS
echo 'OSI_TIMEZONE             ' $OSI_TIMEZONE
echo 'OSI_ADDITIONAL_SOFTWARE  ' $OSI_ADDITIONAL_SOFTWARE
echo ''

echo ":: creating user ${OSI_USER_NAME}"
sudo useradd -G wheel ${OSI_USER_NAME} -m || {
    echo "failed to create user '${OSI_USER_NAME}'"
    exit 1
}

echo ":: setting up password for user ${OSI_USER_NAME}"
echo "${OSI_USER_NAME}":"${OSI_USER_PASSWORD}" | sudo chpasswd || {
    echo "failed to set user password"
    exit 1
}

echo ":: setting up password for user ${OSI_USER_NAME}"
echo "root":"${OSI_USER_PASSWORD}" | sudo chpasswd || {
    echo "failed to set superuser password"
    exit 1
}

sudo rm -f /etc/lightdm/lightdm.conf.d/*-initial-setup.conf

if [[ ${OSI_USER_AUTOLOGIN} == 1 ]] ; then
echo ":: enabling autologin for ${OSI_USER_NAME}"
sudo install -vDm644 /dev/stdin /etc/lightdm/lightdm.conf.d/autologin.conf << EOF
[SeatDefaults]
autologin-user=${OSI_USER_NAME}
autologin-user-timeout=0
autologin-session=xfce
EOF
fi

echo ":: setting up locale: ${OSI_LOCALE}"
sudo install -vDm644 /dev/stdin /etc/locale.conf << EOF
LANG=${OSI_LOCALE}
EOF

echo ":: setting up timezone: ${OSI_TIMEZONE}"
sudo ln -sf /usr/share/zoneinfo/${OSI_TIMEZONE} /etc/localtime

echo ":: updating bootloader"
sudo update-grub

exit 0