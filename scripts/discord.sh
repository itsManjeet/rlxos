#!/bin/sh

while true; do
    echo "listening bolt input"
    while read line; do
        DISCORD_CHANNELID=766878995517145118 bolt-sendmesg "${line}"
    done <$(pwd)/discord-bolt
done