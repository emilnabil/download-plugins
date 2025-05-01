#!/bin/bash

ZIP_FILE="Vhannibal Hot Bird + DTT Lombardia.zip"
EXTRACT_DIR="/tmp/extracted_settings"

if [ -f /etc/apt/apt.conf ]; then
    INSTALL="apt-get install -y"
    OPKGREMOVE="apt-get purge --auto-remove -y"
    CHECK_INSTALLED="dpkg -l"
    OS="DreamOS"
elif [ -f /etc/opkg/opkg.conf ]; then
    INSTALL="opkg install"
    OPKGREMOVE="opkg remove --force-depends"
    CHECK_INSTALLED="opkg list-installed"
    OS="Opensource"
else
    echo "Unsupported OS"
    exit 1
fi

cd /tmp || exit 1

# Install required packages
for cmd in wget unzip; do
    if ! command -v "$cmd" > /dev/null 2>&1; then
        echo "$cmd not found, installing..."
        if ! $INSTALL "$cmd"; then
            echo "Failed to install $cmd"
            exit 1
        fi
    fi
done

# Download settings
echo "Downloading latest file..."
if ! wget -q --show-progress -O "/tmp/$ZIP_FILE" "https://www.vhannibal.net/autosetting/download.php?id=17&action=download"; then
    echo "Download failed."
    exit 1
fi

# Clean old settings
echo "Cleaning old settings..."
rm -rf /etc/enigma2/*.tv /etc/enigma2/*.radio

# Extract and copy
mkdir -p "$EXTRACT_DIR"
if ! unzip -q -j "/tmp/$ZIP_FILE" -d "$EXTRACT_DIR"; then
    echo "Failed to unzip $ZIP_FILE"
    exit 1
fi

cp -rf "$EXTRACT_DIR"/* /etc/enigma2/

if [ $? -eq 0 ]; then
    echo "Files copied to /etc/enigma2/ successfully."
else
    echo "Failed to copy files to /etc/enigma2/"
    exit 1
fi

# Cleanup
echo "Cleaning up temporary files..."
rm -rf "$EXTRACT_DIR"
rm -f "/tmp/$ZIP_FILE"

echo "   UPLOADED BY  >>>>   EMIL_NABIL "

# Restart GUI
sleep 3
echo 'RESTARTING GUI ...'
sync
sleep 2
if command -v systemctl > /dev/null 2>&1; then
    systemctl restart enigma2
else
    killall -9 enigma2
fi

exit 0


