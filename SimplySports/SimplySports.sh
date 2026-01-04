#!/bin/bash

echo "Removing previous version ..."
sleep 2

# Check if the directory exists before removing it
if [ -d /usr/lib/enigma2/python/Plugins/Extensions/SimplySports ]; then
    rm -rf /usr/lib/enigma2/python/Plugins/Extensions/SimplySports > /dev/null 2>&1
    echo 'Package removed.'
else
    echo "You do not have previous version"
fi

opkg install curl
sleep 2

# Download and extract the package
cd /tmp || exit
curl -k -Lbk -m 55532 -m 555104 "https://dreambox4u.com/emilnabil237/skins/skins-aglare-fhd.tar.gz" -o /tmp/SimplySports.tar.gz
sleep 1
echo "Installing ...."
tar -xzf /tmp/SimplySports.tar.gz -C /
echo ""
echo ""
sleep 1
rm -f /tmp/SimplySports.tar.gz
sleep 2
exit 0




