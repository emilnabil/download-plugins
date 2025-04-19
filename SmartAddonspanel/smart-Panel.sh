#!/bin/bash
##setup command=wget https://raw.githubusercontent.com/emilnabil/download-plugins/main/SmartAddonspanel/smart-Panel.sh -O - | /bin/sh

########
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
    echo "You have Python3 image"
    PYTHON="PY3"
    Packagesix="python3-six"
    Packagerequests="python3-requests"
else
    echo "You have Python2 image"
    PYTHON="PY2"
    Packagerequests="python-requests"
fi

if [ "$PYTHON" = "PY3" ] && ! grep -qs "Package: $Packagesix" "$STATUS"; then
    opkg update && opkg install "$Packagesix"
fi

if ! grep -qs "Package: $Packagerequests" "$STATUS"; then
    echo "Need to install $Packagerequests"
    if [ "$OSTYPE" = "DreamOs" ]; then
        apt-get update && apt-get install "$Packagerequests" -y
    else
        opkg update && opkg install "$Packagerequests"
    fi
fi

[ -d "$TMPPATH" ] && rm -rf "$TMPPATH"
[ -d "$PLUGINPATH" ] && rm -rf "$PLUGINPATH"
mkdir -p "$TMPPATH"

cd /tmp

if [ "$PYTHON" = "PY3" ]; then
    echo "Downloading Python 3 version of SmartAddonspanel..."
    wget "$PLUGIN_URL/Py3/SmartAddonspanel.tar.gz" -O "/tmp/SmartAddonspanel.tar.gz"
else
    echo "Downloading Python 2 version of SmartAddonspanel..."
    wget "$PLUGIN_URL/Py2/SmartAddonspanel.tar.gz" -O "/tmp/SmartAddonspanel.tar.gz"
fi

if [ $? -ne 0 ]; then
    echo "Failed to download the plugin. Exiting."
    exit 1
fi

tar -xzf "/tmp/SmartAddonspanel.tar.gz"
if [ $? -ne 0 ]; then
    echo "Failed to extract the plugin. Exiting."
    exit 1
fi

cp -r "/tmp/SmartAddonspanel/usr" "/"
sync

echo "#########################################################"
echo "#    Smart Addons panel INSTALLED SUCCESSFULLY          #"
echo "#                  Moded by Emil Nabil                  #"
echo "#########################################################"

if [ ! -d /usr/lib64 ]; then
    RESTART_CMD="killall -9 enigma2"
else
    RESTART_CMD="systemctl restart enigma2"
fi

cd /tmp || exit 1
rm -rf "$TMPPATH" /tmp/SmartAddonspanel.tar.gz > /dev/null 2>&1
sync

echo "#########################################################"
echo "#           Your device will RESTART now                #"
echo "#########################################################"
sleep 5
$RESTART_CMD

exit 0

