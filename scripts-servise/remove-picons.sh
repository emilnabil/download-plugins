#!/bin/sh

echo "> Removing picons, please wait..."
sleep 2

# 
PICON_PATHS="
/usr/share/enigma2/picon
/usr/share/enigma2/XPicon/picon
/usr/share/enigma2/ZZPicon/picon
/media/hdd/picon
/media/ba/picon
/media/ba/XPicon/picon
/media/ba/ZZicon/picon
/media/hdd/XPicon/picon
/media/hdd/ZZicon/picon
/media/usb/picon
/media/usb/XPicon/picon
/media/usb/ZZicon/picon
/media/sdcard/picon
/media/mmc/picon
/data/picon
/picon
"

for path in $PICON_PATHS; do
    rm -rf "$path" > /dev/null 2>&1
done

echo "> Done"
sleep 2
exit
