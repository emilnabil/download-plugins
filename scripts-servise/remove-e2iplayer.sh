#!/bin/sh

echo "> removing e2iplayer please wait..."
sleep 3

rm -rf /usr/lib/enigma2/python/Plugins/Extensions/IPTVPlayer > /dev/null 2>&1

rm -rf /etc/IPTVCache > /dev/null 2>&1

rm -rf /iptvplayer_rootfs > /dev/null 2>&1

rm -rf /etc/IPTVCache > /dev/null 2>&1

rm -rf /etc/tsiplayer_xtream.conf > /dev/null 2>&1

rm -rf /media/hdd/IPTVCache > /dev/null 2>&1


echo "> done
> your device will restart now please wait ..."
sleep 3
init 4
sleep 1
sed -i '/iptvplayer/d' /etc/enigma2/settings
sed -e s/config.plugins.iptvplayer.*//g -i /etc/enigma2/settings
if [ $OSTYPE = "DreamOS" ]; then
sleep 2
systemctl restart enigma2
else
init 3
fi

