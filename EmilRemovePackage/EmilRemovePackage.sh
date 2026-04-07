#!/bin/sh
##command=wget -q "--no-check-certificate" https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilRemovePackage/EmilRemovePackage.sh -O - | /bin/sh

set -e

echo "Removing old package..."
rm -rf /usr/lib/enigma2/python/Plugins/Extensions/EmilRemovePackage

echo "Installing plugin..."
cd /tmp || { echo "Failed to enter /tmp"; exit 1; }

if command -v wget >/dev/null 2>&1; then
    echo "Downloading using wget..."
    wget -q --no-check-certificate -O EmilRemovePackage.tar.gz "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilRemovePackage/EmilRemovePackage.tar.gz"
elif command -v curl >/dev/null 2>&1; then
    echo "Downloading using curl..."
    curl -k -L -o EmilRemovePackage.tar.gz "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilRemovePackage/EmilRemovePackage.tar.gz"
else
    echo "Error: neither wget nor curl is available to download the file."
    exit 1
fi

if [ ! -f EmilRemovePackage.tar.gz ]; then
    echo "Error: failed to download the file."
    exit 1
fi

echo "Extracting..."
tar -xzf EmilRemovePackage.tar.gz -C /
sleep 1

echo "Cleaning temporary files..."
rm -f EmilRemovePackage.tar.gz

echo "Installation successful."
exit 0
