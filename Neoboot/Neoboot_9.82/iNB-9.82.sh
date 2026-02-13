#!/bin/sh
##Command=wget https://github.com/emilnabil/download-plugins/raw/refs/heads/main/Neoboot/Neoboot_9.82/iNB-9.82.sh -O - | /bin/sh
##################################
set -e

URL="https://github.com/emilnabil/download-plugins/raw/refs/heads/main/Neoboot/Neoboot_9.82/neoboot_9.82.tar.gz"
FILE="/tmp/neoboot_9.82.tar.gz"

echo "==============================================="
echo "              NeoBoot Installer"
echo "==============================================="

if [ -e /.multinfo ]; then
    echo "ERROR: Install NeoBoot only from FLASH image!"
    exit 1
fi

if [ -f /etc/apt/apt.conf ]; then
    OS="DreamOS"
else
    OS="OpenSource"
fi

echo "Downloading NeoBoot..."

cd /tmp
rm -f "$FILE"

wget --no-check-certificate "$URL" -O "$FILE"

if [ ! -f "$FILE" ]; then
    echo "ERROR: Download failed!"
    exit 1
fi

echo "Extracting package..."

tar -xzf /tmp/neoboot_9.82.tar.gz -C /

if [ $? -ne 0 ]; then
    echo "ERROR: Extraction failed!"
    rm -f "$FILE"
    exit 1
fi

rm -f "$FILE"

echo "NeoBoot installed successfully."

sleep 2

echo "Restarting Enigma2..."

if [ "$OS" = "DreamOS" ]; then
    systemctl restart enigma2
else
    killall enigma2
fi

exit 0



