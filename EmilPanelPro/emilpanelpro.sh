#!/bin/bash
##setup command=wget https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilPanelPro/emilpanelpro.sh -O - | /bin/sh

########

TMPPATH="/tmp/EmilPanelPro"
PLUGIN_URL="https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilPanelPro"

if [ ! -d /usr/lib64 ]; then
    PLUGINPATH="/usr/lib/enigma2/python/Plugins/Extensions/EmilPanelPro"
else
    PLUGINPATH="/usr/lib64/enigma2/python/Plugins/Extensions/EmilPanelPro"
fi

if [ -f /var/lib/dpkg/status ]; then
    STATUS="/var/lib/dpkg/status"
    OSTYPE="DreamOs"
else
    STATUS="/var/lib/opkg/status"
    OSTYPE="Dream"
fi

if python --version 2>&1 | grep -q '^Python 3\.'; then
    echo "You have Python3 image"
    PYTHON="PY3"
    Packagesix="python3-six"
    Packagerequests="python3-requests"
else
    echo "You have Python2 image"
    PYTHON="PY2"
    Packagerequests="python-requests"
fi

if [ "$PYTHON" = "PY3" ]; then
    if ! grep -qs "Package: $Packagesix" "$STATUS"; then
        opkg update && opkg install "$Packagesix"
    fi
fi

if ! grep -qs "Package: $Packagerequests" "$STATUS"; then
    echo "Need to install $Packagerequests"
    if [ "$OSTYPE" = "DreamOs" ]; then
        apt-get update && apt-get install "$Packagerequests" -y
    else
        opkg update && opkg install "$Packagerequests"
    fi
fi

echo "Installing required core packages..."
opkg update
opkg install python python-core python-json python-netclient python-codecs python-xml python-shell python-subprocess python-multiprocessing
opkg install wget curl busybox tar gzip
opkg install enigma2-plugin-systemplugins-skinselector enigma2-plugin-extensions-openwebif
opkg install opkg

[ -d "$TMPPATH" ] && rm -rf "$TMPPATH"
[ -d "$PLUGINPATH" ] && rm -rf "$PLUGINPATH"
mkdir -p "$TMPPATH"

cd "$TMPPATH" || exit 1

wget "$PLUGIN_URL/EmilPanelPro.tar.gz" -O EmilPanelPro.tar.gz

if [ -f EmilPanelPro.tar.gz ]; then
    tar -xzf EmilPanelPro.tar.gz -C /

    echo "#########################################################"
    echo "#    Emil Panel INSTALLED SUCCESSFULLY                  #"
    echo "#########################################################"

    if [ ! -d /usr/lib64 ]; then
        RESTART_CMD="killall -9 enigma2"
    else
        RESTART_CMD="systemctl restart enigma2"
    fi

    cd /tmp || exit 1
    rm -rf "$TMPPATH" /tmp/EmilPanelPro.tar.gz > /dev/null 2>&1
    sync

    echo "#########################################################"
    echo "#           Your device will RESTART now                #"
    echo "#########################################################"
    sleep 5
    $RESTART_CMD

    exit 0
else
    echo "#########################################################"
    echo "#    ERROR: Failed to download EmilPanelPro.tar.gz      #"
    echo "#########################################################"
    rm -rf "$TMPPATH"
    exit 1
fi

