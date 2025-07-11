#!/bin/sh

    if [ -f /etc/apt/apt.conf ]; then
    apt-get upgrade
    else
    opkg upgrade
    fi
exit
