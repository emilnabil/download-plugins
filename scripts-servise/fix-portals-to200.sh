#!/bin/sh
echo "> downloading and installing file please wait..."
sleep 3

wget -O /usr/lib/enigma2/python/Plugins/Extensions/MultiStalker/commons/commons.py https://gitlab.com/eliesat/extensions/-/raw/main/multistalker/commons.py

echo "> done"
sleep 3
killall -9 enigma2



