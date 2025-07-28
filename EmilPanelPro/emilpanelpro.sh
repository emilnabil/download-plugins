#!/bin/bash
##setup command=wget https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilPanelPro/emilpanelpro.sh -O - | /bin/sh

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
    INSTALLER="apt-get"
else
    STATUS="/var/lib/opkg/status"
    OSTYPE="Dream"
    INSTALLER="opkg"
fi

if command -v python3 >/dev/null 2>&1; then
    PYTHON_CMD="python3"
elif command -v python >/dev/null 2>&1; then
    PYTHON_CMD="python"
elif command -v python2 >/dev/null 2>&1; then
    PYTHON_CMD="python2"
else
    echo "✘ Python is not installed."
    exit 1
fi

if $PYTHON_CMD -c 'import sys; exit(0) if sys.version_info[0] == 3 else exit(1)'; then
    echo "✔ Python3 image detected"
    PYTHON="py3"
    Packagesix="python3-six"
    Packagerequests="python3-requests"
else
    echo "✔ Python2 image detected"
    PYTHON="py2"
    Packagesix=""
    Packagerequests="python-requests"
fi

if [ "$PYTHON" = "py3" ] && ! grep -qs "Package: $Packagesix" "$STATUS"; then
    echo "Installing $Packagesix ..."
    opkg update >/dev/null 2>&1
    opkg install "$Packagesix" >/dev/null 2>&1
fi

if ! grep -qs "Package: $Packagerequests" "$STATUS"; then
    echo "Installing $Packagerequests ..."
    if [ "$INSTALLER" = "apt-get" ]; then
        apt-get update >/dev/null 2>&1
        apt-get install "$Packagerequests" -y >/dev/null 2>&1
    else
        opkg update >/dev/null 2>&1
        opkg install "$Packagerequests" >/dev/null 2>&1
    fi
fi

rm -rf "$TMPPATH" "$PLUGINPATH"
mkdir -p "$TMPPATH"

cd /tmp || exit 1

echo "Downloading EmilPanelPro ($PYTHON version)..."
wget -q "$PLUGIN_URL/${PYTHON}/EmilPanelPro.tar.gz" -O "/tmp/EmilPanelPro.tar.gz"
if [ $? -ne 0 ]; then
    echo "✘ Failed to download the plugin."
    exit 1
fi

tar -xzf "/tmp/EmilPanelPro.tar.gz" -C / >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "✘ Failed to extract the plugin."
    exit 1
fi

sync

echo "#########################################################"
echo "#  ✔ EmilPanelPro INSTALLED SUCCESSFULLY               #"
echo "#         Modified & Uploaded by Emil Nabil            #"
echo "#########################################################"

rm -rf "$TMPPATH" "/tmp/EmilPanelPro.tar.gz"
sync

exit 0


