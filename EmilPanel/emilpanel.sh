#!/bin/bash
#
##setup command=wget https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilPanel/emilpanel.sh -O - | /bin/sh

TMPPATH="/tmp/EmilPanel"
PLUGIN_URL="https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilPanel"

# Detect plugin path
if [ -d /usr/lib64 ]; then
    PLUGINPATH="/usr/lib64/enigma2/python/Plugins/Extensions/EmilPanel"
else
    PLUGINPATH="/usr/lib/enigma2/python/Plugins/Extensions/EmilPanel"
fi

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
    echo "#   ERROR: Failed to download emilpanel.tar.gz         #"
    echo "#########################################################"
    exit 1
fi

echo "#########################################################"
echo "#        Emil Panel INSTALLED SUCCESSFULLY             #"
echo "#########################################################"

echo "Cleaning up..."
rm -rf "$TMPPATH" /tmp/emilpanel.tar.gz >/dev/null 2>&1
sync

sleep 3
exit 0


