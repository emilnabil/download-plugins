#!/bin/bash

echo "> Updating satellites.xml file, please wait..."
sleep 2

DEST="/etc/tuxbox/satellites.xml"
URL="https://raw.githubusercontent.com/OpenPLi/tuxbox-xml/master/xml/satellites.xml"
TEMP_FILE="${DEST}.tmp"

mkdir -p "$(dirname "$DEST")" || {
    echo "> ERROR: Failed to create directory $(dirname "$DEST")"
    exit 1
}

if wget --timeout=30 --tries=2 --no-check-certificate -q -O "$TEMP_FILE" "$URL"; then
    
    if [ -s "$TEMP_FILE" ] && grep -q '<satellites>' "$TEMP_FILE"; then
        mv -f "$TEMP_FILE" "$DEST"
        echo "> satellites.xml updated successfully."
        sleep 2
        echo "> Restarting Enigma2 to apply changes..."
        
        if [ -f /etc/init.d/enigma2 ]; then
            /etc/init.d/enigma2 restart
        else
            killall -9 enigma2
        fi
    else
        echo "> ERROR: Downloaded file is invalid or empty"
        rm -f "$TEMP_FILE"
        exit 1
    fi
else
    echo "> ERROR: Failed to download satellites.xml"
    exit 1
fi

