#!/bin/sh
##command=wget https://github.com/emilnabil/download-plugins/raw/refs/heads/main/PluginBrowser-Grid/pluginbrowser-grid.sh -O - | /bin/sh
#####################

cd /usr/lib/enigma2/python/Screens || exit 1

cp PluginBrowser.pyc PluginBrowser.pyc.bak

wget -q https://github.com/emilnabil/download-plugins/raw/refs/heads/main/PluginBrowser-Grid/PluginBrowser.py -O PluginBrowser.py

if [ $? -ne 0 ]; then
    cp PluginBrowser.pyc.bak PluginBrowser.pyc
    exit 1
fi

sleep 2
killall -9 enigma2
exit 0
