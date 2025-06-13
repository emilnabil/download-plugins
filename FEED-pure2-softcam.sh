#!/bin/bash

#remove feed
if [ -f /etc/opkg/external-extra-feed.conf ]; then

echo "> Removing pure2 secret Feed Please Wait ..."
sleep 3
rm -rf /etc/opkg/external-extra-feed.conf > /dev/null 2>&1
rm -rf /var/lib/opkg/lists/* > /dev/null 2>&1
opkg update

echo "*******************************************"
echo "*             Removed Finished            *"
echo "*******************************************"
sleep 3

else
echo "> Installing pure2 secret Feed Please Wait ..."
sleep 3

#check arch armv7l aarch64 mips 7401c0 sh4
arch=$(uname -m)

if [ "$arch" == "mips" ]; then
echo "src/gz external-extra_feed http://pur-e2.club/cam/6.1/mipsel" >>/etc/opkg/external-extra-feed.conf

elif [ "$arch" == "armv7l" ]; then
echo "src/gz cams http://pur-e2.club/cam/6.1/arm" >>/etc/opkg/external-extra-feed.conf

else echo "> your arch $: $arch is not supported"
sleep 3
exit 1
fi
opkg update
echo " "
sleep 3
echo "> pure2 secret Feed installed successfully"
sleep 3

fi
