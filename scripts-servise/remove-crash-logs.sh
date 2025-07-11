#!/bin/sh

echo "> removing files please wait..."
sleep 3

for file in /home/root /home/root/logs /media/hdd /media/usb /media/mmc /tmp /; do
rm -rf $file/*.log > /dev/null 2>&1
done 
echo "> done"
sleep 3