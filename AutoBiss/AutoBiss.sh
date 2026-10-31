#!/bin/sh
### wget --no-check-certificate -O - https://github.com/emilnabil/download-plugins/raw/refs/heads/main/AutoBiss/AutoBiss.sh | /bin/sh

echo " Download And Install Plugin AutoBiss "

TEMPATH=/tmp
MY_IPK="enigma2-plugin-extensions-autobiss_all.ipk"
MY_DEB="enigma2-plugin-extensions-autobiss_all.deb"
MY_URL="https://github.com/emilnabil/download-plugins/raw/refs/heads/main/AutoBiss"

OS="Unknown"
if [ -f /etc/apt/apt.conf ]; then
    OS='DreamOS'
    STATUS='/var/lib/dpkg/status'
elif [ -f /etc/opkg/opkg.conf ]; then
    OS='Opensource'
    STATUS='/var/lib/opkg/status'
else
    echo " [!] Unsupported system. Aborting."
    exit 1
fi
echo " Detected system: $OS"

if ! which wget > /dev/null 2>&1; then
    echo " [!] wget not found. Trying to install..."
    if [ "$OS" = 'DreamOS' ]; then
        apt-get update && apt-get install -y wget
    else
        opkg update && opkg install wget
    fi
fi

echo " Removing old version ..."
if [ "$OS" = 'DreamOS' ]; then
    dpkg --purge --force-all enigma2-plugin-extensions-autobiss > /dev/null 2>&1
else
    opkg remove --force-depends enigma2-plugin-extensions-autobiss > /dev/null 2>&1
fi
rm -rf /usr/lib/enigma2/python/Plugins/Extensions/AutoBiss
echo ""

cd "$TEMPATH" || { echo " [!] Cannot cd to $TEMPATH"; exit 1; }

if which dpkg > /dev/null 2>&1; then
    echo " Downloading DEB package ..."
    rm -f "$MY_DEB"
    if ! wget -q --no-check-certificate "$MY_URL/$MY_DEB"; then
        echo " [!] Download failed. Aborting."
        exit 1
    fi
    echo " Installing DEB package ..."
    dpkg -i --force-overwrite "$MY_DEB"
    apt-get install -f -y
    sleep 2
    rm -f "$MY_DEB"
else
    echo " Downloading IPK package ..."
    rm -f "$MY_IPK"
    if ! wget -q --no-check-certificate "$MY_URL/$MY_IPK"; then
        echo " [!] Download failed. Aborting."
        exit 1
    fi
    echo " Installing IPK package ..."
    opkg install --force-overwrite "$MY_IPK"
    sleep 2
    rm -f "$MY_IPK"
fi

echo "================================="
cd / || true

echo "********************************************************************************"
echo "   UPLOADED BY  >>>>   EMIL_NABIL "
sleep 3
echo "#                Restart Enigma2 GUI                    #"
echo "#########################################################"
sleep 2

if [ "$OS" = 'DreamOS' ]; then
    systemctl restart enigma2
else
    killall -9 enigma2 2>/dev/null || true
fi

exit 0
