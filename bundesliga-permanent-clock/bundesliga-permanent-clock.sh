#!/bin/sh
## Command=wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/bundesliga-permanent-clock/bundesliga-permanent-clock.sh -O - | /bin/sh
##
PLUGIN_DIR="/usr/lib/enigma2/python/Plugins/Extensions/BundesligaPermanentClock"
STATUS_FILE="/var/lib/opkg/status"
PACKAGE_NAME="enigma2-plugin-extensions-bundesligapermanentclock"
TMP_DIR="/var/volatile/tmp"
PLUGIN="bundesliga-permanent-clock"
URL="https://github.com/emilnabil/download-plugins/raw/refs/heads/main/bundesliga-permanent-clock/bundesliga-permanent-clock.tar.gz"
PACKAGE_PATH="$TMP_DIR/${PLUGIN}.tar.gz"

if [ -d "$PLUGIN_DIR" ]; then
    echo "> Removing package, please wait..."
    sleep 1
    rm -rf "$PLUGIN_DIR"

    if opkg list-installed | grep -q "^$PACKAGE_NAME "; then
        opkg remove "$PACKAGE_NAME" >/dev/null 2>&1
    fi

    echo "*******************************************"
    echo "*             Removal Finished            *"
    echo "*******************************************"
    sleep 1
fi

echo "> Downloading ${PLUGIN} package, please wait..."
sleep 2

if wget -q -O "$PACKAGE_PATH" --no-check-certificate "$URL"; then
    echo "> Extracting package..."
    if tar -xzf "$PACKAGE_PATH" -C /; then
        echo "> ${PLUGIN} package installed successfully"
    else
        echo "> Package extraction failed"
        rm -f "$PACKAGE_PATH"
        exit 1
    fi
    rm -f "$PACKAGE_PATH"
else
    echo "> Failed to download ${PLUGIN} package"
    exit 1
fi

exit 0



