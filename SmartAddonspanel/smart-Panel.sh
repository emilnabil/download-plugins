#!/bin/bash
##setup command=wget https://raw.githubusercontent.com/emilnabil/download-plugins/main/SmartAddonspanel/smart-Panel.sh -O - | /bin/sh

changelog='\nFix little bugs\nUpdated Picons List'

TMPPATH="/tmp/SmartAddonspanel"
PLUGIN_URL="https://raw.githubusercontent.com/emilnabil/download-plugins/main/SmartAddonspanel"

if [ ! -d /usr/lib64 ]; then
    PLUGINPATH="/usr/lib/enigma2/python/Plugins/Extensions/SmartAddonspanel"
else
    PLUGINPATH="/usr/lib64/enigma2/python/Plugins/Extensions/SmartAddonspanel"
fi

if [ -f /var/lib/dpkg/status ]; then
    STATUS="/var/lib/dpkg/status"
    OSTYPE="DreamOs"
else
    STATUS="/var/lib/opkg/status"
    OSTYPE="Dream"
fi

if python --version 2>&1 | grep -q '^Python 3\.'; then
    echo "✔ Python3 image detected"
    PYTHON="PY3"
    Packagesix="python3-six"
    Packagerequests="python3-requests"
else
    echo "✔ Python2 image detected"
    PYTHON="PY2"
    Packagesix=""
    Packagerequests="python-requests"
fi

if [ "$PYTHON" = "PY3" ] && ! grep -qs "Package: $Packagesix" "$STATUS"; then
    echo "Installing $Packagesix ..."
    opkg update >/dev/null 2>&1
    opkg install "$Packagesix" >/dev/null 2>&1
fi

if ! grep -qs "Package: $Packagerequests" "$STATUS"; then
    echo "Installing $Packagerequests ..."
    if [ "$OSTYPE" = "DreamOs" ]; then
        apt-get update >/dev/null 2>&1
        apt-get install "$Packagerequests" -y >/dev/null 2>&1
    else
        opkg update >/dev/null 2>&1
        opkg install "$Packagerequests" >/dev/null 2>&1
    fi
fi

[ -d "$TMPPATH" ] && rm -rf "$TMPPATH"
[ -d "$PLUGINPATH" ] && rm -rf "$PLUGINPATH"
mkdir -p "$TMPPATH"

cd /tmp || exit 1

if [ "$PYTHON" = "PY3" ]; then
    echo "Downloading Python 3 version..."
    wget -q "$PLUGIN_URL/Py3/SmartAddonspanel.tar.gz" -O "/tmp/SmartAddonspanel.tar.gz"
else
    echo "Downloading Python 2 version..."
    wget -q "$PLUGIN_URL/Py2/SmartAddonspanel.tar.gz" -O "/tmp/SmartAddonspanel.tar.gz"
fi

if [ $? -ne 0 ]; then
    echo "✘ Failed to download the plugin."
    exit 1
fi

tar -xzf "/tmp/SmartAddonspanel.tar.gz" >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "✘ Failed to extract the plugin."
    exit 1
fi

cp -r "/tmp/SmartAddonspanel/usr" "/" >/dev/null 2>&1
sync

echo "#########################################################"
echo "#  ✔ SmartAddonspanel INSTALLED SUCCESSFULLY           #"
echo "#         Modified & Uploaded by Emil Nabil            #"
echo "#########################################################"

cd /tmp || exit 1
rm -rf "$TMPPATH" "/tmp/SmartAddonspanel.tar.gz" >/dev/null 2>&1
sync

exit 0


