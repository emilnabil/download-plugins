#!/bin/bash
#
##setup command=wget https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilPanel/emilpanel.sh -O - | /bin/sh

TMPPATH="/tmp/EmilPanel"
PLUGIN_URL="https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilPanel"

if [ -d /usr/lib64 ]; then
    PLUGINPATH="/usr/lib64/enigma2/python/Plugins/Extensions/EmilPanel"
else
    PLUGINPATH="/usr/lib/enigma2/python/Plugins/Extensions/EmilPanel"
fi

if [ -f /var/lib/dpkg/status ]; then
    STATUS="/var/lib/dpkg/status"
    OSTYPE="DreamOs"
else
    STATUS="/var/lib/opkg/status"
    OSTYPE="Dream"
fi

echo "Checking Python version..."
if python --version 2>&1 | grep -q '^Python 3\.'; then
    echo "You have Python3 image"
    PYTHON="PY3"
    Packagesix="python3-six"
    Packagerequests="python3-requests"
else
    echo "Python 2 is not supported for this plugin."
    sleep 2
    exit 1
fi

if ! grep -qs "Package: $Packagesix" "$STATUS"; then
    echo "Installing $Packagesix..."
    opkg update > /dev/null 2>&1
    opkg install "$Packagesix" > /dev/null 2>&1
fi

if ! grep -qs "Package: $Packagerequests" "$STATUS"; then
    echo "Installing $Packagerequests..."
    if [ "$OSTYPE" = "DreamOs" ]; then
        apt-get update > /dev/null 2>&1
        apt-get install "$Packagerequests" -y > /dev/null 2>&1
    else
        opkg update > /dev/null 2>&1
        opkg install "$Packagerequests" > /dev/null 2>&1
    fi
fi

echo "Installing required core packages..."
opkg update > /dev/null 2>&1
opkg install python python-core python-json python-netclient python-codecs python-xml python-shell python-subprocess python-multiprocessing > /dev/null 2>&1
opkg install wget curl busybox tar gzip > /dev/null 2>&1
opkg install enigma2-plugin-systemplugins-skinselector enigma2-plugin-extensions-openwebif > /dev/null 2>&1
opkg install opkg > /dev/null 2>&1

echo "Cleaning previous installation..."
rm -rf "$TMPPATH" "$PLUGINPATH"
mkdir -p "$TMPPATH"

cd "$TMPPATH" || exit 1

echo "Downloading plugin..."
wget "$PLUGIN_URL/emilpanel.tar.gz" -O emilpanel.tar.gz > /dev/null 2>&1

if [ -f emilpanel.tar.gz ]; then
    echo "Extracting plugin..."
    tar -xzf emilpanel.tar.gz -C / > /dev/null 2>&1
    sync
else
    echo "#########################################################"
    echo "#  ERROR: Failed to download emilpanel.tar.gz          #"
    echo "#########################################################"
    exit 1
fi

echo "#########################################################"
echo "#      Emil Panel INSTALLED SUCCESSFULLY               #"
echo "#########################################################"

echo "Cleaning up..."
rm -rf "$TMPPATH" /tmp/emilpanel.tar.gz > /dev/null 2>&1
sync

echo "#########################################################"
echo "#########################################################"
sleep 5

exit 0


