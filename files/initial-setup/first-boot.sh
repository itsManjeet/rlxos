#!/bin/bash

# sanity check that all variables were set
if [ -z ${ISE_USERNAME+x}  ] || \
   [ -z ${ISE_PASSWORD+x}  ] || \
   [ -z ${ISE_AUTOLOGIN+x} ] || \
   [ -z ${ISE_UPDATE_ROOT_PASSWORD+x} ]
then
    echo "Configure script called without all environment variables set!"
    exit 1
fi

echo ":: Creating user ${ISE_USERNAME}"
sudo useradd -G wheel,docker,audio,video,kvm,netdev ${ISE_USERNAME} -m >/dev/null || {
    echo "failed to create user '${ISE_USERNAME}'"
    exit 1
}

echo ":: Setting up password for user ${ISE_USERNAME}"
echo "${ISE_USERNAME}":"${ISE_PASSWORD}" | sudo chpasswd || {
    echo "failed to set user password"
    exit 1
}

if [[ ${ISE_UPDATE_ROOT_PASSWORD} -eq 1 ]] ; then
echo ":: Setting up password for user root"
echo "root":"${ISE_PASSWORD}" | sudo chpasswd || {
    echo "failed to set superuser password"
    exit 1
}
fi

sudo rm -f /etc/lightdm/lightdm.conf.d/*-initial-setup.conf

if [[ ${ISE_AUTOLOGIN} -eq 1 ]] ; then
echo ":: Enabling autologin for ${ISE_USERNAME}"
sudo install -D -m644 /dev/stdin /etc/lightdm/lightdm.conf.d/autologin.conf << EOF
[SeatDefaults]
autologin-user=${ISE_USERNAME}
autologin-user-timeout=0
autologin-session=xfce
EOF
fi

#echo ":: setting up locale: ${ISE_LOCALE}"
#sudo install -vDm644 /dev/stdin /etc/locale.conf << EOF
#LANG=${OSI_LOCALE}
#EOF

#echo ":: setting up timezone: ${ISE_TIMEZONE}"
#sudo ln -sf /usr/share/zoneinfo/${OSI_TIMEZONE} /etc/localtime

exit 0