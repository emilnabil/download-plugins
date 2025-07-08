#!/bin/sh

for dir in /media/hdd /media/usb /media/mmc /media/ba
do
if [ -d $dir/xtraEvent/noinfos ]; then
echo "> folder found"
break
fi
done
sleep 1

echo "> removing unnecessary files please wait ..."
sleep 3

rm -rf /$dir/xtraEvent/noinfos/*.json >/dev/null 

echo "> done"
sleep 3
exit

