#!/bin/sh
##command=wget -q "--no-check-certificate" https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilRemovePackage/EmilRemovePackage.sh -O - | /bin/sh
#############################

if [ -f /var/lib/dpkg/status ]; then
    STATUS="/var/lib/dpkg/status"
    OSTYPE="DreamOS"
    INSTALLER="apt-get"
elif [ -f /var/lib/opkg/status ]; then
    STATUS="/var/lib/opkg/status"
    OSTYPE="Dream"
    INSTALLER="opkg"
else
    echo "✘ Unsupported package system"
    exit 1
fi

set -e

for cmd in wget tar; do
    if ! command -v "$cmd" > /dev/null 2>&1; then
        echo "✘ $cmd not found. Please install $cmd first."
        exit 1
    fi
done

echo "Removing old package..."
rm -rf /usr/lib/enigma2/python/Plugins/Extensions/EmilRemovePackage

echo "Installing plugin..."

if ! cd /tmp; then
    echo "✘ Failed to enter /tmp"
    exit 1
fi

if [ "$OSTYPE" = "DreamOS" ]; then
    URL="https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilRemovePackage/dreamos/EmilRemovePackage.tar.gz"
else
    URL="https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilRemovePackage/EmilRemovePackage.tar.gz"
fi

echo "Downloading from $URL ..."
if ! wget -q --no-check-certificate -O EmilRemovePackage.tar.gz "$URL"; then
    echo "✘ Error: failed to download the file."
    exit 1
fi

if [ ! -f EmilRemovePackage.tar.gz ] || [ ! -s EmilRemovePackage.tar.gz ]; then
    echo "✘ Error: downloaded file is missing or empty."
    rm -f EmilRemovePackage.tar.gz
    exit 1
fi

echo "Extracting..."
if ! tar -xzf EmilRemovePackage.tar.gz -C /; then
    echo "✘ Error: extraction failed."
    rm -f EmilRemovePackage.tar.gz
    exit 1
fi

echo "Cleaning temporary files..."
rm -f EmilRemovePackage.tar.gz

if pgrep -x "enigma2" > /dev/null; then
    echo "Restarting Enigma2..."
    if [ "$OSTYPE" = "DreamOS" ]; then
        systemctl restart enigma2
    else
        killall -9 enigma2
    fi
fi

echo "✓ Installation successful."
exit 0
