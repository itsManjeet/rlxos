#!/bin/bash

useradd -m liveuser -g users -G adm
echo -e 'liveuser\nliveuser' | passwd liveuser