#!/bin/sh

echo "> removing tuner settings please wait..."
sleep 3
echo "> your device will restart now please wait..."
init 4
sleep 1
sed -i '/config.Nims.0/d' /etc/enigma2/settings
sleep 4
init 3
exit
