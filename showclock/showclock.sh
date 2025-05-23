#!/bin/bash
#
rm -rf /usr/lib/enigma2/python/Plugins/Extensions/ShowClock
# Download and extract the package
cd /tmp || exit
curl -k -Lbk -m 55532 -m 555104 "https://dreambox4u.com/emilnabil237/skins/skins-aglare-fhd.tar.gz" -o /tmp/showclock.tar.gz
sleep 1
echo "Installing ...."
tar -xzf /tmp/showclock.tar.gz -C /
echo ""
echo ""
sleep 1
rm -f /tmp/showclock.tar.gz
sleep 2
exit 0





