#!/bin/bash
# Command=wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/levi45emulator/installer.sh -O - | /bin/sh

##########################################
echo ">>> Download And Install Plugin Levi45 Emulator <<<"
TEMPATH="/tmp"
MY_NAME="enigma2-plugin-extensions-levi45emulator_all"
MY_IPK="${MY_NAME}.ipk"
MY_DEB="${MY_NAME}.deb"
MY_URL="https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/levi45emulator"

# Detect system type
if which dpkg > /dev/null 2>&1; then
    STATUS="/var/lib/dpkg/status"
    OS="DreamOS"
elif which opkg > /dev/null 2>&1; then
    STATUS="/var/lib/opkg/status"
    OS="Opensource"
else
    echo "Unsupported system!"
    exit 1
fi

# Remove old version
echo ">>> Removing old version..."
opkg remove enigma2-plugin-extensions-levi45emulator 2>/dev/null
rm -rf /usr/lib/enigma2/python/Plugins/Extensions/Levi45Emulator

cd "$TEMPATH" || exit 1
set -e

# Download & install
if [ "$OS" = "DreamOS" ]; then
    wget -q --show-progress "${MY_URL}/${MY_DEB}"
    dpkg -i --force-overwrite "$MY_DEB" || apt-get install -f -y
    rm -f "$MY_DEB"
else
    wget -q --show-progress "${MY_URL}/${MY_IPK}"
    opkg install --force-overwrite "$MY_IPK"
    rm -f "$MY_IPK"
fi

set +e
cd ..

echo "================================="
echo "   UPLOADED BY  >>>>   EMIL_NABIL "
sleep 4
echo "#                Restarting Enigma2 GUI                    #"
echo "#########################################################"
sleep 2

if [ "$OS" = "DreamOS" ]; then
    systemctl restart enigma2
else
    killall -9 enigma2
fi

exit 0

