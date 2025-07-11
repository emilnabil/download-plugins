#!/bin/sh

    if [ -f /etc/apt/apt.conf ]; then
    apt-get update
    else
    opkg update
    fi
exit
