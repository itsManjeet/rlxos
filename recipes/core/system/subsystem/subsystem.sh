#!/bin/bash

XAUTH=/tmp/container_xauth
xauth nextract - "$DISPLAY" | sed -e 's/^..../ffff/' | xauth -f "$XAUTH" nmerge -

if [[ ! -d ${HOME}/share ]] ; then
    install -v -d -m 0755 -o ${USER} ${HOME}/share
fi

pkexec /bin/systemd-nspawn -D /subsystem            \
    --bind=/tmp/.X11-unix               \
    --bind="$XAUTH"                     \
    --bind=${HOME}/share:/home/rlxos    \
    --bind=${PWD}:/run/${PWD}           \
    --chdir=/run/${PWD}                 \
    -E DISPLAY="$DISPLAY"               \
    --user=rlxos                        \
    -E XAUTHORITY="$XAUTH" ${@}

rm -f /tmp/container_xauth