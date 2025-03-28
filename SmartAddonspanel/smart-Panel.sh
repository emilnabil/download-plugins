#!/bin/bash
## Setup command:
## wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/SmartAddonspanel/smart-Panel.sh -O - | /bin/sh

######### Only These 2 lines to edit with new version ######
version='4.0.2'
changelog='\nFix little bugs\nUpdated Picons List'

TMPPATH="/tmp/SmartAddonspanel"
PLUGIN_URL="https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/SmartAddonspanel"

PLUGINPATH="/usr/lib/enigma2/python/Plugins/Extensions/SmartAddonspanel"
[ -d /usr/lib64 ] && PLUGINPATH="/usr/lib64/enigma2/python/Plugins/Extensions/SmartAddonspanel"

if [ -f /var/lib/dpkg/status ]; then
    STATUS="/var/lib/dpkg/status"
    OSTYPE="DreamOs"
    PKG_MGR="apt-get"
    INSTALL_CMD="install -y"
else
    STATUS="/var/lib/opkg/status"
    OSTYPE="Dream"
    PKG_MGR="opkg"
    INSTALL_CMD="install"
fi

PYTHON=""
Packagesix=""
Packagerequests=""
PLUGIN_SUBDIR=""

if command -v python3 >/dev/null 2>&1 && python3 --version 2>&1 | grep -q '^Python 3\.'; then
    echo "You have Python3 image"
    PYTHON="PY3"
    Packagesix="python3-six"
    Packagerequests="python3-requests"
    PLUGIN_SUBDIR="Py3"
elif command -v python >/dev/null 2>&1; then
    if python --version 2>&1 | grep -q '^Python 3\.'; then
        echo "You have Python3 image"
        PYTHON="PY3"
        Packagesix="python3-six"
        Packagerequests="python3-requests"
        PLUGIN_SUBDIR="Py3"
    else
        echo "You have Python2 image"
        PYTHON="PY2"
        Packagerequests="python-requests"
        PLUGIN_SUBDIR="Py2"
    fi
else
    echo "Python is not installed!"
    exit 1
fi

if [ "$PYTHON" = "PY3" ] && ! grep -qs "Package: $Packagesix" "$STATUS"; then
    echo "Installing $Packagesix..."
    $PKG_MGR update && $PKG_MGR $INSTALL_CMD "$Packagesix"
fi

if ! grep -qs "Package: $Packagerequests" "$STATUS"; then
    echo "Installing $Packagerequests..."
    $PKG_MGR update && $PKG_MGR $INSTALL_CMD "$Packagerequests"
fi

rm -rf "$TMPPATH" "$PLUGINPATH"
mkdir -p "$TMPPATH"

echo "Downloading $PYTHON version of SmartAddonspanel..."
wget -q "$PLUGIN_URL/$PLUGIN_SUBDIR/SmartAddonspanel.tar.gz" -O "/tmp/SmartAddonspanel.tar.gz"

if [ -f "/tmp/SmartAddonspanel.tar.gz" ]; then
    tar -xzf "/tmp/SmartAddonspanel.tar.gz" -C "/tmp"
    cp -r "/tmp/SmartAddonspanel/usr" "/"
    sync

    echo "#########################################################"
    echo "#    Smart Addons panel INSTALLED SUCCESSFULLY          #"
    echo "#                  Moded by Emil Nabil                  #"
    echo "#########################################################"
else
    echo "Failed to download SmartAddonspanel.tar.gz!"
    exit 1
fi

RESTART_CMD="systemctl restart enigma2"
[ ! -d /usr/lib64 ] && RESTART_CMD="killall -9 enigma2"

rm -rf "$TMPPATH" "/tmp/SmartAddonspanel.tar.gz"
sync

echo "#########################################################"
echo "#           Your device will RESTART now                #"
echo "#########################################################"
sleep 5
$RESTART_CMD

exit 0



