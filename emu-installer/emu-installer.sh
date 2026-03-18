#!/bin/bash
## command=wget https://github.com/emilnabil/download-plugins/raw/refs/heads/main/emu-installer/emu-installer.sh -O - | /bin/sh
#####################################

echo "Removing previous version of emu-installer..."
sleep 2

if [ -d /usr/lib/enigma2/python/Plugins/Extensions/EmuInstaller ]; then
    rm -rf /usr/lib/enigma2/python/Plugins/Extensions/EmuInstaller > /dev/null 2>&1
    echo 'Package removed.'
else
    echo "You do not have previous version"
fi

echo ""
opkg install curl
sleep 2

cd /tmp || exit
curl -k -Lbk -m 55532 -m 555104 "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/emu-installer/emuinstaller.tar.gz" -o /tmp/emuinstaller.tar.gz
sleep 1

echo "Installing ...."
tar -xzf /tmp/emuinstaller.tar.gz -C /
echo ""
echo ""
sleep 1

rm -f /tmp/emuinstaller.tar.gz

echo ">>>>>>>>>>>>>>>>>>> DONE <<<<<<<<<<<<<<<<<<<<<"
sleep 2
exit 0

