#!/bin/bash
##setup command=wget https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilPanel/emilpanel.sh -O - | /bin/sh

########

TMPPATH="/tmp/EmilPanel"
PLUGIN_URL="https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilPanel"

# Define plugin path based on system architecture
if [ ! -d /usr/lib64 ]; then
    PLUGINPATH="/usr/lib/enigma2/python/Plugins/Extensions/EmilPanel"
else
    PLUGINPATH="/usr/lib64/enigma2/python/Plugins/Extensions/EmilPanel"
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

# Clean temporary and plugin directories
[ -d "$TMPPATH" ] && rm -rf "$TMPPATH"
[ -d "$PLUGINPATH" ] && rm -rf "$PLUGINPATH"
mkdir -p "$TMPPATH"

# Download and extract plugin
cd "$TMPPATH" || exit 1

if [ "$PYTHON" = "PY3" ]; then
    echo "Downloading Python 3 version of EmilPanel..."
    wget "$PLUGIN_URL/emilpanel.tar.gz" -O emilpanel.tar.gz
    if [ -f emilpanel.tar.gz ]; then
        tar -xzf emilpanel.tar.gz -C /
        sync
    else
        echo "Failed to download plugin archive."
        exit 1
    fi
else
    echo "Python 2 is not supported for this plugin."
    sleep 2
    exit 1
fi

# Output success message
echo "#########################################################"
echo "#    Emil Panel INSTALLED SUCCESSFULLY                  #"
echo "#########################################################"

# Determine restart command
if [ ! -d /usr/lib64 ]; then
    RESTART_CMD="killall -9 enigma2"
else
    RESTART_CMD="systemctl restart enigma2"
fi

# Clean temporary files
cd /tmp || exit 1
rm -rf "$TMPPATH" /tmp/emilpanel.tar.gz > /dev/null 2>&1
sync

# Restart device
echo "#########################################################"
echo "#           Your device will RESTART now                #"
echo "#########################################################"
sleep 5
$RESTART_CMD

exit 0




