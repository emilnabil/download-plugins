#!/bin/sh

# Check and install wget
#######################################
    if [ -f /etc/apt/apt.conf ]; then
    apt-get update >/dev/null 2>&1
    apt install wget -y
    elif [ -f /etc/opkg/opkg.conf ]; then
    opkg update > /dev/null 2>&1
    opkg install wget
    else
    echo "> wget package is already installed"
    fi