#!/bin/bash

echo "Removing previous version of GT-IPTV-PlayerPro..."
sleep 2

# Check if the directory exists before removing it
if [ -d /usr/lib/enigma2/python/Plugins/Extensions/GTIPTVPlayerPro ]; then
    rm -rf /usr/lib/enigma2/python/Plugins/Extensions/GTIPTVPlayerPro > /dev/null 2>&1
    echo 'Package removed.'
else
    echo "You do not have previous version"
fi

echo ""
opkg install enigma2 python3-core python3-compression python3-crypt python3-datetime python3-difflib python3-fcntl python3-html python3-io python3-json python3-math python3-netclient python3-netserver python3-stringold python3-threading python3-xml 
opkg install curl
sleep 2

# Download and extract the package
cd /tmp || exit
curl -k -Lbk -m 55532 -m 555104 "https://dreambox4u.com/emilnabil237/skins/skins-aglare-fhd.tar.gz" -o /tmp/skins-aglare-fhd.tar.gz
sleep 1
echo "Installing ...."
tar -xzf /tmp/skins-aglare-fhd.tar.gz -C /
echo ""
echo ""
sleep 1
rm -f /tmp/skins-aglare-fhd.tar.gz
sleep 2
exit 0





