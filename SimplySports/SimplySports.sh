#!/bin/bash
# setup command:
## wget https://github.com/emilnabil/download-plugins/raw/refs/heads/main/SimplySports/SimplySports.sh -O - | /bin/sh
##################

echo "===================================="
echo "   SimplySports Plugin Installer"
echo "===================================="
sleep 2

TARGET_DIR="/usr/lib/enigma2/python/Plugins/Extensions/SimplySports"
DOWNLOAD_URL="https://github.com/emilnabil/download-plugins/raw/refs/heads/main/SimplySports/SimplySports.tar.gz"
TEMP_FILE="/tmp/SimplySports.tar.gz"

echo "Removing previous version..."
if [ -d "$TARGET_DIR" ]; then
    rm -rf "$TARGET_DIR" >/dev/null 2>&1
    echo "Previous version removed."
else
    echo "No previous version found."
fi
sleep 1

if ! command -v curl >/dev/null 2>&1; then
    echo "curl not found, installing..."
    opkg update >/dev/null 2>&1
    opkg install curl >/dev/null 2>&1
    sleep 2
fi

echo "Downloading package..."
cd /tmp || exit 1

if curl -k -L --connect-timeout 30 --max-time 300 -o "$TEMP_FILE" "$DOWNLOAD_URL"; then
    echo "Extracting package..."
    tar -xzf "$TEMP_FILE" -C / >/dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo "Installation completed successfully."
    else
        echo "Error: Extraction failed."
        exit 1
    fi
else
    echo "Error: Download failed."
    exit 1
fi

rm -f "$TEMP_FILE" >/dev/null 2>&1

echo "Restarting Enigma2..."
sleep 2
if command -v systemctl >/dev/null 2>&1; then
    systemctl restart enigma2
else
    killall -9 enigma2 >/dev/null 2>&1
fi

exit 0


