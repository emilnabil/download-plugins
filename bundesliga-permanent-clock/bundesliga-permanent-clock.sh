#!/bin/sh

PLUGIN_DIR="/usr/lib/enigma2/python/Plugins/Extensions/BundesligaPermanentClock"
STATUS_FILE="/var/lib/opkg/status"
PACKAGE_NAME="enigma2-plugin-extensions-bundesligapermanentclock"

if [ -d "$PLUGIN_DIR" ]; then
    echo "> Removing package, please wait..."
    rm -rf "$PLUGIN_DIR" > /dev/null 2>&1

    if grep -q "$PACKAGE_NAME" "$STATUS_FILE"; then
        opkg remove "$PACKAGE_NAME" > /dev/null 2>&1
    fi

    echo "*******************************************"
    echo "*             Removal Finished            *"
    echo "*******************************************"
fi

# Plugin details
PLUGIN="bundesliga-permanent-clock"
VERSION="1.0"
URL="https://gitlab.com/eliesat/extensions/-/raw/main/bundesliga-permanent-clock/bundesliga-permanent-clock-1.0.tar.gz"
PACKAGE_PATH="/var/volatile/tmp/${PLUGIN}.tar.gz"

# Download & install
echo "> Downloading ${PLUGIN} package, please wait..."
sleep 2

if wget -O "$PACKAGE_PATH" --no-check-certificate "$URL"; then
    if tar -xzf "$PACKAGE_PATH" -C /; then
        echo "> ${PLUGIN} package installed successfully"
    else
        echo "> ${PLUGIN} package installation failed"
        sleep 2
    fi
    rm -rf "$PACKAGE_PATH" >/dev/null 2>&1
else
    echo "> Failed to download ${PLUGIN}-${VERSION} package"
fi

exit 0


