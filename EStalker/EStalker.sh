#!/bin/bash
#
##setup command=wget https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EStalker/EStalker.sh -O - | /bin/sh
#
echo "==============================================="
echo "       Download And Install Plugin estalker     "
echo "==============================================="

TEMPATH="/tmp"
OPKGINSTALL="opkg install --force-overwrite"
MY_IPK="enigma2-plugin-extensions-estalker_all.ipk"
MY_DEB="enigma2-plugin-extensions-estalker_all.deb"
MY_URL="https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EStalker"

# Detect system type
if [ -f /etc/apt/apt.conf ]; then
    STATUS='/var/lib/dpkg/status'
    OS='DreamOS'
elif [ -f /etc/opkg/opkg.conf ]; then
    STATUS='/var/lib/opkg/status'
    OS='Opensource'
else
    echo "❌ Unknown OS type"
    exit 1
fi

echo "==> Removing old version..."
opkg remove enigma2-plugin-extensions-estalker > /dev/null 2>&1
rm -rf /usr/lib/enigma2/python/Plugins/Extensions/EStalker
echo ""

cd $TEMPATH || exit 1
set -e

# Download and install the correct package
if which dpkg > /dev/null 2>&1; then
    wget -q "$MY_URL/$MY_DEB"
    dpkg -i --force-overwrite $MY_DEB
    apt-get install -f -y
    rm -f $MY_DEB
else
    wget -q "$MY_URL/$MY_IPK"
    $OPKGINSTALL $MY_IPK
    rm -f $MY_IPK
fi

echo "==============================================="
echo "✅ Plugin estalker installed successfully"
echo "==============================================="
set +e

echo ""
echo "************************************************"
echo "   UPLOADED BY  >>>>   EMIL_NABIL              "
echo "************************************************"
sleep 4

echo ""
echo "################################################"
echo "#         Restarting Enigma2 GUI              #"
echo "################################################"
sleep 2

if [ "$OS" = "DreamOS" ]; then
    systemctl restart enigma2
else
    killall -9 enigma2
fi

exit 0


