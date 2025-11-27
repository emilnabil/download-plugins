#!/bin/bash
#
##setup command=wget https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilPanel/emilpanel.sh -O - | /bin/sh

TMPPATH="/tmp/EmilPanel"

# Detect system type and set plugin URL
if [ -f /var/lib/dpkg/status ]; then
    STATUS="/var/lib/dpkg/status"
    OSTYPE="DreamOS"
    INSTALLER="apt-get"
    PLUGIN_URL="https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilPanel/dreamos"
elif [ -f /var/lib/opkg/status ]; then
    STATUS="/var/lib/opkg/status"
    OSTYPE="OpenSource" 
    INSTALLER="opkg"
    PLUGIN_URL="https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilPanel/OpenSource"
else
    echo "#########################################################"
    echo "#      ✘ Unsupported package system.                  #"
    echo "#########################################################"
    exit 1
fi

# Detect plugin path
if [ -d /usr/lib64 ]; then
    PLUGINPATH="/usr/lib64/enigma2/python/Plugins/Extensions/EmilPanel"
else
    PLUGINPATH="/usr/lib/enigma2/python/Plugins/Extensions/EmilPanel"
fi

echo "#########################################################"
echo "#           Detected System: $OSTYPE                   #"
echo "#           Installer: $INSTALLER                      #"
echo "#########################################################"

echo "Cleaning previous installation..."
rm -rf "$TMPPATH" "$PLUGINPATH"
mkdir -p "$TMPPATH"

cd "$TMPPATH" || exit 1

echo "Downloading plugin for $OSTYPE..."
echo "URL: $PLUGIN_URL/emilpanel.tar.gz"
wget "$PLUGIN_URL/emilpanel.tar.gz" -O emilpanel.tar.gz >/dev/null 2>&1

if [ -f emilpanel.tar.gz ]; then
    echo "Extracting plugin..."
    tar -xzf emilpanel.tar.gz -C / >/dev/null 2>&1
    sync
else
    echo "#########################################################"
    echo "#   ERROR: Failed to download emilpanel.tar.gz         #"
    echo "#   System: $OSTYPE                                    #"
    echo "#   URL: $PLUGIN_URL/emilpanel.tar.gz                  #"
    echo "#########################################################"
    exit 1
fi

echo "#########################################################"
echo "#        Emil Panel INSTALLED SUCCESSFULLY             #"
echo "#                System: $OSTYPE                        #"
echo "#########################################################"

echo "Cleaning up..."
rm -rf "$TMPPATH"
sync

sleep 3
exit 0


