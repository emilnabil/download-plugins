#!/bin/bash

echo "Removing previous version ..."
sleep 2

# Check if the directory exists before removing it
if [ -d /usr/lib/enigma2/python/Plugins/Extensions/EmilBootLogos ]; then
    rm -rf /usr/lib/enigma2/python/Plugins/Extensions/EmilBootLogos > /dev/null 2>&1
    echo 'Package removed.'
else
    echo "You do not have previous version"
fi

echo ""
opkg install curl
sleep 2

# Download and extract the package
cd /tmp || exit
curl -k -Lbk -m 55532 -m 555104 "https://dreambox4u.com/emilnabil237/skins/skins-aglare-fhd.tar.gz" -o /tmp/EmilBootLogos.tar.gz
sleep 1
echo "Installing ...."
tar -xzf /tmp/EmilBootLogos.tar.gz -C /
echo ""
echo ""
sleep 1
rm -f /tmp/EmilBootLogos.tar.gz

echo ">>>>>>>>>>Uploaded by Emil Nabil <<<<<<<<<<"
sleep 2
exit 0





