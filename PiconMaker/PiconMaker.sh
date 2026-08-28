#!/bin/bash

##setup command=wget --no-check-certificate -O - https://github.com/emilnabil/download-plugins/raw/refs/heads/main/PiconMaker/PiconMaker.sh | /bin/sh


TMPPATH="/tmp/EmilPanelPro"
PLUGIN_ARCHIVE="PiconMaker.tar.gz"

if command -v apt-get &>/dev/null; then
    INSTALLER="apt-get"
    SYSTEM="DreamOS"
    echo "Detected: DreamOS"
elif command -v opkg &>/dev/null; then
    INSTALLER="opkg"
    SYSTEM="OpenSource"
    echo "Detected: OpenSource Enigma2"
else
    echo "No supported package manager found!"
    exit 1
fi

if command -v python3 &>/dev/null; then
    PYTHON_CMD="python3"
    PYTHON_VER="3"
    echo "Python 3 detected"
elif command -v python &>/dev/null; then
    PYTHON_CMD="python"
    PYTHON_VER="2"
    echo "Python 2 detected"
else
    echo "Python is not installed!"
    exit 1
fi

echo "Removing old versions..."
if [ "$INSTALLER" = "opkg" ]; then
    opkg remove enigma2-plugin-extensions-piconmaker --force-depends 2>/dev/null
elif [ "$INSTALLER" = "apt-get" ]; then
    dpkg --remove enigma2-plugin-extensions-piconmaker 2>/dev/null
    apt-get remove -y enigma2-plugin-extensions-piconmaker 2>/dev/null
fi
rm -rf /usr/lib/enigma2/python/Plugins/Extensions/PiconMaker

echo "Updating package lists..."
$INSTALLER update

echo "Installing required packages..."
if [ "$INSTALLER" = "opkg" ]; then
    opkg install curl wget
else
    apt-get install -y curl wget
fi

echo "Downloading plugin..."
rm -rf "$TMPPATH"
mkdir -p "$TMPPATH"
cd "$TMPPATH"

if [ "$SYSTEM" = "DreamOS" ]; then
    URL="https://github.com/emilnabil/download-plugins/raw/refs/heads/main/PiconMaker/Dreambox/PiconMaker.tar.gz"
else
    URL="https://github.com/emilnabil/download-plugins/raw/refs/heads/main/PiconMaker/PiconMaker.tar.gz"
fi

wget "$URL" -O "$PLUGIN_ARCHIVE"

if [ $? -ne 0 ] || [ ! -f "$PLUGIN_ARCHIVE" ]; then
    echo "❌ Download failed!"
    cd /
    rm -rf "$TMPPATH"
    exit 1
fi

echo "Extracting files..."
tar -xzf "$PLUGIN_ARCHIVE" -C /

if [ $? -ne 0 ]; then
    echo "❌ Extraction failed!"
    cd /
    rm -rf "$TMPPATH"
    exit 1
fi

cd /
rm -rf "$TMPPATH"
sync

echo "========================================"
echo "✅ PiconMaker Installed Successfully!"
echo "📁 Location: /usr/lib/enigma2/python/Plugins/Extensions/PiconMaker"
echo "========================================"

echo "Restarting Enigma2 in 3 seconds..."
sleep 3

if command -v systemctl &>/dev/null; then
    systemctl restart enigma2
else
    killall -9 enigma2 2>/dev/null || init 4 && sleep 2 && init 3
fi

exit 0
