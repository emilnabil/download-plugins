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

echo "Installing required packages..."
if [ "$OSTYPE" = "DreamOs" ]; then
    apt-get update >/dev/null 2>&1
    apt-get install -y python3-six python3-requests python3 python3-core python3-json python3-netclient python3-codecs python3-xml python3-shell python3-subprocess python3-multiprocessing >/dev/null 2>&1
else
    opkg update >/dev/null 2>&1
    opkg install python3-six python3-requests python3 python3-core python3-json python3-netclient python3-codecs python3-xml python3-shell python3-subprocess python3-multiprocessing >/dev/null 2>&1
fi

opkg install wget curl busybox tar gzip >/dev/null 2>&1
opkg install enigma2-plugin-systemplugins-skinselector enigma2-plugin-extensions-openwebif >/dev/null 2>&1
opkg install opkg >/dev/null 2>&1

echo "Cleaning previous installation..."
rm -rf "$TMPPATH" "$PLUGINPATH"
mkdir -p "$TMPPATH"

cd "$TMPPATH" || exit 1

echo "Downloading plugin..."
wget "$PLUGIN_URL/emilpanel.tar.gz" -O emilpanel.tar.gz >/dev/null 2>&1

if [ -f emilpanel.tar.gz ]; then
    echo "Extracting plugin..."
    tar -xzf emilpanel.tar.gz -C / >/dev/null 2>&1
    sync
else
    echo "#########################################################"
    echo "#  ERROR: Failed to download emilpanel.tar.gz          #"
    echo "#  Please upload the plugin file to your repository    #"
    echo "#########################################################"
    exit 1
fi

echo "#########################################################"
echo "#         Emil Panel INSTALLED SUCCESSFULLY            #"
echo "#########################################################"

echo "Cleaning up..."
rm -rf "$TMPPATH" /tmp/emilpanel.tar.gz >/dev/null 2>&1
sync

echo "#########################################################"
echo "#########################################################"
sleep 5

exit 0


