#!/bin/bash
##Command=wget --no-check-certificate -O - https://github.com/emilnabil/download-plugins/raw/refs/heads/main/E2BissKeysEditor/E2BissKeysEditor.sh -O - | /bin/sh
############################
echo "Removing previous version of Skin..."
sleep 2

if [ -d /usr/share/enigma2/SmooGemini ]; then
    opkg remove enigma2-skin-smoogemini
    rm -rf /usr/lib/enigma2/python/Plugins/Extensions/Smoo >/dev/null 2>&1
    rm -rf /usr/share/enigma2/SmooGemini >/dev/null 2>&1
    echo "Package removed."
else
    echo "You do not have previous version"
fi

echo ""
opkg install curl
sleep 2

cd /tmp || exit
curl -k -L "https://github.com/emilnabil/skins-openatv/raw/refs/heads/main/skin-smoogemini.tar.gz" -o /tmp/skin-smoogemini.tar.gz
sleep 2

echo "Installing ...."
tar -xzf /tmp/skin-smoogemini.tar.gz -C /
echo ""
echo ""

sleep 1
rm -f /tmp/skin-smoogemini.tar.gz
echo " Uploaded By Emil Nabil"
sleep 2
exit 0








