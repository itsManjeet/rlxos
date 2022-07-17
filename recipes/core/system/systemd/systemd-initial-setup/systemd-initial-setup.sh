#!/bin/bash

chvt 2

cat /etc/passwd | grep "/home" && {
    echo "already setup"
    exit 0
}

function check() {
    local ret=${?}
    if [[ ${ret} != 0 ]] ; then
        echo "process failed with exit code: ${ret}"
    fi
}

function SetLocale() {
    echo -n "Enter your locale or press enter to view avaliable locales: "
    read LANG

    if [[ -z ${LANG} ]] ; then
        localectl list-locales
        SetLocale
    else
        echo "setting locale ${LANG}..."
        localectl set-locale ${LANG}
        check
        export LANG
    fi
}

function SetTimeZone() {
    echo -n "Enter your Timezone or press enter to view list: "
    read TIMEZONE
    if [[ -z ${TIMEZONE} ]] ; then
        timedatectl list-timezones
        SetTimeZone
    else
        echo "setting timezone ${TIMEZONE}..."
        timedatectl set-timezone ${TIMEZONE}
        check
    fi
}

function CreateUser() {
    local USER

    while [[ -z ${USER} ]] ; do
        echo -n "Enter username: "
        read USER
    done

    useradd -g users -m -G adm ${USER}
    check

    passwd ${USER}
    check
}

function setupRootPasswd() {
    echo "Enter root user passwd"
    passwd root
}

function SetKeymap() {
    echo -n "Enter your keymap: "
    read KEYMAP

    if [[ -z ${KEYMAP} ]] ; then
        localectl list-keymaps
        setupKeymap
    else
        echo "setting keymaps"
        localectl set-keymaps ${KEYMAP}
        check
    fi
}


SetLocale
SetKeymap
SetTimeZone
setupRootPasswd
CreateUser