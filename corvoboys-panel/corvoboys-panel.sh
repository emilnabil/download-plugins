#!/bin/bash
##Command=wget https://dreambox4u.com/emilnabil237/skins/openatv/nacht_7.1.sh -O - | /bin/sh
####################
echo "Removing previous version..."
sleep 2

# Check if the directory exists before removing it
if [ -d /usr/lib/enigma2/python/Plugins/Extensions/cbPanel ]; then
    rm -rf /usr/lib/enigma2/python/Plugins/Extensions/cbPanel
    echo 'Package removed.'
else
    echo "You do not have previous version"
fi

echo ""
opkg install curl
sleep 2

# Download and extract the package
cd /tmp || exit
curl -k -Lbk -m 55532 -m 555104 "https://dreambox4u.com/emilnabil237/skins/openatv/skins-nacht_7.1.tar.gz" -o /tmp/cbPanel.tar.gz
sleep 1
echo "Installing ...."
tar -xzf /tmp/cbPanel.tar.gz -C /
echo ""
echo ""
sleep 1
rm -f /tmp/cbPanel.tar.gz
sleep 2
exit 0











