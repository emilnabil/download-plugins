#!/bin/bash
#
##setup command=wget https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EStalker/EStalker.sh -O - | /bin/sh

PLUGIN_URL="https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EStalker"

if [ -d /usr/lib64 ]; then
    PLUGINPATH="/usr/lib64/enigma2/python/Plugins/Extensions/EStalker"
    RESTART_CMD="systemctl restart enigma2"
else
    PLUGINPATH="/usr/lib/enigma2/python/Plugins/Extensions/EStalker"
    RESTART_CMD="killall -9 enigma2"
fi

if [ -f /var/lib/dpkg/status ]; then
    STATUS="/var/lib/dpkg/status"
    OSTYPE="DreamOs"
    PACKAGER="apt-get"
else
    STATUS="/var/lib/opkg/status"
    OSTYPE="Dream"
    PACKAGER="opkg"
fi

#
echo "Checking Python version..."
PYV="$(python -V 2>&1)"
echo "$PYV"
echo ""

#
echo "Updating package manager..."
if [ "$PACKAGER" = "opkg" ]; then
    opkg update > /dev/null 2>&1
else
    apt-get update > /dev/null 2>&1
fi

#
if [[ "$PYV" =~ "Python 3" ]]; then
    REQS=("requests" "multiprocessing" "six")
    for pkg in "${REQS[@]}"; do
        echo "Checking python3-$pkg..."
        python -c "import $pkg" 2>/dev/null || $PACKAGER install -y "python3-$pkg" > /dev/null 2>&1
    done
else
    echo "Checking python-requests..."
    python -c "import requests" 2>/dev/null || $PACKAGER install -y python-requests > /dev/null 2>&1

    echo "Checking python-multiprocessing..."
    python -c "from multiprocessing.pool import ThreadPool" 2>/dev/null || $PACKAGER install -y python-multiprocessing > /dev/null 2>&1

    echo "Checking python-image..."
    python -c "import PIL" 2>/dev/null || { $PACKAGER install -y python-image > /dev/null 2>&1; $PACKAGER install -y python-imaging > /dev/null 2>&1; }

    echo "Checking python-six..."
    python -c "import six" 2>/dev/null || $PACKAGER install -y python-six > /dev/null 2>&1
fi

if [ "$PACKAGER" = "opkg" ]; then
    echo ""
    echo "Installing system packages..."
    opkg install python python-core python-json python-netclient python-codecs python-xml python-shell python-subprocess python-multiprocessing > /dev/null 2>&1
    opkg install wget curl busybox tar gzip > /dev/null 2>&1
    opkg install enigma2-plugin-systemplugins-skinselector enigma2-plugin-extensions-openwebif > /dev/null 2>&1
    opkg install opkg > /dev/null 2>&1
fi

echo ""
echo "Cleaning previous plugin installation..."
rm -rf "$PLUGINPATH"
cd /tmp || exit 1

echo "Downloading plugin..."
if ! command -v wget >/dev/null 2>&1; then
    echo "ERROR: wget not found!"
    exit 1
fi

wget "$PLUGIN_URL/Estalker.tar.gz" -O Estalker.tar.gz > /dev/null 2>&1

if [ -f Estalker.tar.gz ]; then
    echo "Extracting plugin..."
    tar -xzf Estalker.tar.gz -C / > /dev/null 2>&1
    sync

    echo "#########################################################"
    echo "#        EStalker INSTALLED SUCCESSFULLY                #"
    echo "#########################################################"

    echo "Cleaning temporary files..."
    rm -f /tmp/Estalker.tar.gz > /dev/null 2>&1
    sync

    echo "#########################################################"
    echo "#           Your device will RESTART now                #"
    echo "#########################################################"
    sleep 5
    $RESTART_CMD
    exit 0
else
    echo "#########################################################"
    echo "#  ERROR: Failed to download Estalker.tar.gz            #"
    echo "#########################################################"
    exit 1
fi


