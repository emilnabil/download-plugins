#!/bin/bash
#

echo ""

opkg install curl
sleep 2

# Download and extract the package
cd /tmp || exit
curl -k -Lbk -m 55532 -m 555104 "https://dreambox4u.com/emilnabil237/skins/skins-aglare-fhd.tar.gz" -o /tmp/arabic-language_for-openatv-image.tar.gz
sleep 1
echo "Installing ...."
tar -xzf /tmp/arabic-language_for-openatv-image.tar.gz -C /
echo ""
echo ""
sleep 1
rm -f /tmp/arabic-language_for-openatv-image.tar.gz
sleep 2
exit 0



