#!/bin/sh
# setup command=wget https://github.com/emilnabil/download-plugins/raw/refs/heads/main/novaler/ultracam.sh -O - | /bin/sh
########################################
echo -e ">>> \033[0;32mUpdating feeds, please wait...\033[0m"
opkg update > /dev/null 2>&1

PY_VER=$(python3 -c 'import sys; print("%d.%d" % sys.version_info[:2])')
echo -e ">>> Detected Python Version: \033[0;32m$PY_VER\033[0m"

case "$PY_VER" in
    "3.9"|"3.10"|"3.11"|"3.12"|"3.13"|"3.14") 
        PACKAGE="enigma2-plugin-extensions-ultracam-py${PY_VER}_3.0-r0_all.ipk" 
        ;;
    *) 
        echo -e ">>> \033[0;31mError: Python $PY_VER not supported\033[0m"
        exit 1 
        ;;
esac

SERVER_URL="http://ipk.ath.cx/pg/ultracam"
FULL_URL="$SERVER_URL/$PACKAGE"
TMP_FILE="/tmp/plugin_ready.ipk"

echo -e ">>> Downloading: \033[0;33m$PACKAGE\033[0m"
rm -f $TMP_FILE
wget --no-check-certificate "$FULL_URL" -O $TMP_FILE > /dev/null 2>&1

if [ -s "$TMP_FILE" ]; then
    FILE_SIZE=$(stat -c%s "$TMP_FILE")
    if [ "$FILE_SIZE" -gt 10240 ]; then
        echo -e ">>> \033[0;32mInstalling package...\033[0m"
        opkg install --force-depends $TMP_FILE
        if [ $? -eq 0 ]; then
            echo -e ">>> \033[0;32mDone! UltraCam installed successfully.\033[0m"
            echo -e ">>> \033[1;34mRestarting Enigma2 UI, please wait...\033[0m"
            sleep 2
            killall -9 enigma2
        else
            echo -e ">>> \033[0;31mInstallation failed!\033[0m"
        fi
    else
        echo -e ">>> \033[0;31mError: Downloaded file is corrupted or 404 error.\033[0m"
    fi
    rm -f $TMP_FILE
else
    echo -e ">>> \033[0;31mError: Download failed! Check internet connection.\033[0m"
    exit 1
fi
