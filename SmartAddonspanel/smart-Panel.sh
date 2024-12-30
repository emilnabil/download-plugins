#!/bin/bash
##setup command=wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/SmartAddonspanel/smart-Panel.sh -O - | /bin/sh

######### Only These 2 lines to edit with new version ######
version='2.0'
changelog='\nFix little bugs\nUpdated Picons List'

TMPPATH="/tmp/SmartAddonspanel"
PLUGIN_URL="https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/SmartAddonspanel"

# Define plugin path based on system architecture
if [ ! -d /usr/lib64 ]; then
    PLUGINPATH="/usr/lib/enigma2/python/Plugins/Extensions/SmartAddonspanel"
else
    PLUGINPATH="/usr/lib64/enigma2/python/Plugins/Extensions/SmartAddonspanel"
fi

# Determine OS type
if [ -f /var/lib/dpkg/status ]; then
    STATUS="/var/lib/dpkg/status"
    OSTYPE="DreamOs"
else
    STATUS="/var/lib/opkg/status"
    OSTYPE="Dream"
fi

# Check Python version
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

# Install required packages
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

# Clean temporary and plugin directories
[ -d "$TMPPATH" ] && rm -rf "$TMPPATH"
[ -d "$PLUGINPATH" ] && rm -rf "$PLUGINPATH"
mkdir -p "$TMPPATH"

# Download and extract plugin
cd /tmp

if [ "$PYTHON" = "PY3" ]; then
    echo "Downloading Python 3 version of SmartAddonspanel..."
    wget "$PLUGIN_URL/Py3/SmartAddonspanel.tar.gz"
else
    echo "Downloading Python 2 version of SmartAddonspanel..."
    wget "$PLUGIN_URL/Py2/SmartAddonspanel.tar.gz"
fi

tar -xzf "/tmp/SmartAddonspanel.tar.gz"
cp -r "/tmp/SmartAddonspanel/usr" "/"
sync

# Output success message
echo "#########################################################"
echo "#    Smart Addons panel INSTALLED SUCCESSFULLY          #"
echo "#                  Moded by Emil Nabil                  #"
echo "#########################################################"

# Determine restart command
if [ ! -d /usr/lib64 ]; then
    RESTART_CMD="killall -9 enigma2"
else
    RESTART_CMD="systemctl restart enigma2"
fi

# Clean temporary files
cd /tmp || exit 1
rm -rf "$TMPPATH" /tmp/SmartAddonspanel.tar.gz > /dev/null 2>&1
sync

# Restart device
echo "#########################################################"
echo "#           Your device will RESTART now                #"
echo "#########################################################"
sleep 5
$RESTART_CMD

exit 0










