#!/bin/bash

# sanity check that all variables were set
if [ -z ${ISE_USERNAME+x}  ] || \
   [ -z ${ISE_PASSWORD+x}  ] || \
   [ -z ${ISE_AUTOLOGIN+x} ] || \
   [ -z ${ISE_UPDATE_ROOT_PASSWORD+x} ] || \
   [ -z ${ISE_TIMEZONE} ]
then
    echo "Configure script called without all environment variables set!"
    exit 1
fi

echo ":: Creating user ${ISE_USERNAME}"
sudo useradd -G wheel ${ISE_USERNAME} -m >/dev/null || {
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

echo ":: Installing greetd configuration"
sudo install -v -D -m 0644 /dev/stdin /etc/greetd/config.toml << EOF
[terminal]
vt = 1

[default_session]
command = "sway --config /etc/greetd/sway-config"

[initial_session]
command = "sway"
user = "${ISE_USERNAME}"
EOF

if [ -f /etc/lightdm/lightdm.conf.d/*initial-setup*.conf ] ; then
    echo ":: Removing Display manager configuration for inital setup"
    sudo rm -f /etc/lightdm/lightdm.conf.d/*initial-setup*.conf
fi

#echo ":: setting up locale: ${ISE_LOCALE}"
#sudo install -vDm644 /dev/stdin /etc/locale.conf << EOF
#LANG=${OSI_LOCALE}
#EOF

echo ":: setting up timezone: ${ISE_TIMEZONE}"
sudo ln -sf /usr/share/zoneinfo/${ISE_TIMEZONE} /etc/localtime

exit 0