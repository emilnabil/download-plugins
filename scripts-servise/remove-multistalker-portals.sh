#!/bin/sh
#
echo "> Removing MultiStalker portals, please wait..."
sleep 2

init 4
sleep 1

[ -f /home/stalker.conf ] && sed -i '/portal/d' /home/stalker.conf
[ -f /etc/enigma2/settings ] && {
    sed -i '/portal/d' /etc/enigma2/settings
    sed -i '/portals/d' /etc/enigma2/settings
    sed -i 's/config.plugins.MultiStalker.portals.*//g' /etc/enigma2/settings
}

[ -f /etc/enigma2/MultiStalkerPro.json ] && rm -f /etc/enigma2/MultiStalkerPro.json

echo "> Done."
echo "> Your device will restart the GUI now, please wait..."
sleep 2
init 3
exit

