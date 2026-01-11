#!/bin/sh
## Command=wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/backupsuite/backupsuite.sh -O - | /bin/sh
##
PLUGIN_DIR="/usr/lib/enigma2/python/Plugins/Extensions/BackupSuite"
STATUS_FILE="/var/lib/opkg/status"
TMP_DIR="/var/volatile/tmp"
PLUGIN="backupsuite"
VERSION=""
URL="https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/backupsuite/backupsuite.tar.gz"
PACKAGE="$TMP_DIR/$PLUGIN.tar.gz"
PACKAGE_NAME="enigma2-plugin-extensions-backupsuite"

if [ -d "$PLUGIN_DIR" ]; then
    echo "> Removing existing package, please wait..."
    sleep 2
    rm -rf /usr/lib/enigma2/python/Plugins/Extensions/BackupSuite

rm -f /tmp/BackupSuite.log 2>/dev/null || true

    if opkg list-installed | grep -q "^$PACKAGE_NAME "; then
        opkg remove "$PACKAGE_NAME" >/dev/null 2>&1
    fi

    echo "*******************************************"
    echo "*          Removal Completed              *"
    echo "*******************************************"
    sleep 1
fi

for pkg in libc6 libgcc1 libstdc++6; do
    if ! opkg list-installed | grep -q "^$pkg "; then
        echo "> Installing missing dependency: $pkg"
        rm -f /run/opkg.lock
        opkg install "$pkg" >/dev/null 2>&1
    fi
done

echo "> Downloading $PLUGIN-$VERSION package, please wait..."
sleep 1

if wget -q -O "$PACKAGE" --no-check-certificate "$URL"; then
    echo "> Extracting package..."
    if tar -xzf "$PACKAGE" -C /; then
        echo "> $PLUGIN-$VERSION installed successfully"
    else
        echo "> Package extraction failed"
        rm -f "$PACKAGE"
        exit 1
    fi
    rm -f "$PACKAGE"
else
    echo "> Download failed. Please check the URL or your internet connection."
    exit 1
fi
chmod 755 /usr/lib/enigma2/python/Plugins/Extensions/BackupSuite/scripts/*.sh

if [ -f "/usr/bin/ubinize" ]; then
    chmod +x /usr/bin/ubinize
    echo "Fixed ubinize permissions"
fi

if [ -f "/usr/sbin/mkfs.ubifs" ]; then
    chmod +x /usr/sbin/mkfs.ubifs
    echo "Fixed mkfs.ubifs permissions"
fi

if [ -f "/usr/sbin/nanddump" ]; then
    chmod +x /usr/sbin/nanddump
    echo "Fixed nanddump permissions"
fi

if [ -f "/usr/bin/bzip2" ]; then
    chmod +x /usr/bin/bzip2
    echo "Fixed bzip2 permissions"
fi

if [ -f "/usr/bin/bunzip2" ]; then
    chmod +x /usr/bin/bunzip2
    echo "Fixed bunzip2 permissions"
fi

if [ -f "/usr/bin/zip" ]; then
    chmod +x /usr/bin/zip
    echo "Fixed zip permissions"
fi

if [ -f "/usr/sbin/mkfs.jffs2" ]; then
    chmod +x /usr/sbin/mkfs.jffs2
    echo "Fixed mkfs.jffs2 permissions"
fi

if [ -f "/usr/bin/buildimage" ]; then
    chmod +x /usr/bin/buildimage
    echo "Fixed buildimage permissions"
fi
chmod 644 /usr/lib/enigma2/python/Plugins/Extensions/BackupSuite/*.py 2>/dev/null
chmod 644 /usr/lib/enigma2/python/Plugins/Extensions/BackupSuite/*.pyc 2>/dev/null
chmod 644 /usr/lib/enigma2/python/Plugins/Extensions/BackupSuite/*.pyo 2>/dev/null
chmod 644 /usr/lib/enigma2/python/Plugins/Extensions/BackupSuite/*.txt 2>/dev/null
chmod 644 /usr/lib/enigma2/python/Plugins/Extensions/BackupSuite/locale/*/LC_MESSAGES/*.mo 2>/dev/null

# Fix permissions for images
chmod 644 /usr/lib/enigma2/python/Plugins/Extensions/BackupSuite/img/*.png 2>/dev/null

echo "All BackupSuite permissions fixed successfully"

echo "Restarting Enigma2..."
init 4
sleep 2
killall enigma2 > /dev/null 2>&1
sleep 2
init 3

exit 0








