#!/bin/bash
# setup command=wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/enigma2readeradder/enigma2readeradder.sh -O - | /bin/sh

PLUGIN_URL="https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/enigma2readeradder"
PLUGINPATH="/usr/lib/enigma2/python/Plugins/Extensions/Enigma2ReaderAdder"

echo "Removing old plugin directory if exists..."
rm -rf "$PLUGINPATH"

cd /tmp || { echo "Failed to access /tmp directory"; exit 1; }

echo "Downloading plugin archive..."
if wget "$PLUGIN_URL/enigma2readeradder.tar.gz" -O enigma2readeradder.tar.gz > /dev/null 2>&1; then
    echo "Extracting plugin..."
    if tar -xzf enigma2readeradder.tar.gz -C / > /dev/null 2>&1; then
        rm -f enigma2readeradder.tar.gz
        echo "#########################################################"
        echo "#  Enigma2ReaderAdder INSTALLED SUCCESSFULLY           #"
        echo "#########################################################"
        exit 0
    else
        echo "Error: Failed to extract plugin archive."
        exit 2
    fi
else
    echo "Error: Failed to download plugin archive."
    exit 3
fi


