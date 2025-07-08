#!/bin/sh

if [ -f /usr/lib/enigma2/python/Components/Converter/ServiceInfo.pyc ]; then
cp -f '/usr/lib/enigma2/python/Components/Converter/ServiceInfo.pyc' '/usr/lib/enigma2/python/Screens'
echo "> your device will restart now please wait ..."
init 4  
sleep 5 
init 3
fi
exit
