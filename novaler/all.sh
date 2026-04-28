#!/bin/bash

install_process() {
    local DISPLAY_NAME=$1
    local FOLDER_NAME=$2
    local PKG_PREFIX=$3
    local PKG_VERSION=$4

    echo -e "\n>>> \033[0;32mUpdating feeds, please wait...\033[0m"
    opkg update > /dev/null 2>&1

    PY_VER=$(python3 -c 'import sys; print("%d.%d" % sys.version_info[:2])')
    echo -e ">>> Detected Python Version: \033[0;32m$PY_VER\033[0m"

    PACKAGE="${PKG_PREFIX}-py${PY_VER}_${PKG_VERSION}_all.ipk"
    SERVER_URL="http://ipk.ath.cx/pg/$FOLDER_NAME"
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
                echo -e ">>> \033[0;32mDone! $DISPLAY_NAME installed successfully.\033[0m"
                echo -e ">>> \033[1;34mRestarting Enigma2 UI, please wait...\033[0m"
                sleep 2
                killall -9 enigma2
            else
                echo -e ">>> \033[0;31mInstallation failed!\033[0m"
            fi
        else
            echo -e ">>> \033[0;31mError: Downloaded file is corrupted or 404 error.\033[0m"
        fi
    else
        echo -e ">>> \033[0;31mError: Download failed! Check server or internet.\033[0m"
    fi
    rm -f $TMP_FILE
}

clear
echo -e "\033[1;33m****************************************************\033[0m"
echo -e "\033[1;33m*                                                  *\033[0m"
echo -e "\033[1;32m*        WELCOME TO NOVALER TEAM                   *\033[0m"
echo -e "\033[1;32m*        NovaCore Plugin Installer v2.0            *\033[0m"
echo -e "\033[1;33m*                                                  *\033[0m"
echo -e "\033[1;33m****************************************************\033[0m"
echo ""

echo -e "\033[1;36mSelect Plugin to Install:\033[0m"
echo "1) Novaler Store   4) Beengo         7) IPAudio Plus  10) UltraCam"
echo "2) Novacam Pro     5) Novaler TV     8) IP SAT        11) SupTV"
echo "3) NovaTV          6) Total90        9) AirNet-Fn     12) Exit" 
echo "----------------------------------------------------"

read -p "Choice: " choice

case $choice in
    1)  install_process "Novaler Store" "novalerstor" "enigma2-plugin-extensions-novalerstore" "5.0-r0" ;;
    2)  install_process "Novacam Pro" "novacampro" "enigma2-plugin-extensions-novacampro" "4.0-r0" ;;
    3)  install_process "NovaTV" "novatv" "enigma2-plugin-extensions-novatv" "11.0-r0" ;;
    4)  install_process "Beengo" "beengo" "enigma2-plugin-extensions-beengo" "11.0-r0" ;;
    5)  install_process "Novaler TV" "novalertv" "enigma2-plugin-extensions-novalertv" "11.0-r0" ;;
    6)  install_process "Total90" "total90" "enigma2-plugin-extensions-total90" "1.0-r0" ;;
    7)  install_process "IPAudio Plus" "ipaudio" "enigma2-plugin-extensions-ipaudioplus" "5.0-r0" ;;
    8)  install_process "IP SAT" "ipsat" "enigma2-plugin-extensions-ipsat" "11.0-r0" ;;
	9)  install_process "AirNet-Fn" "airnet-fnc" "enigma2-plugin-extensions-airnet-fnc" "5.0-r0" ;;
    10) install_process "UltraCam" "ultracam" "enigma2-plugin-extensions-ultracam" "3.0-r0" ;;
    11) install_process "SupTV" "suptv" "enigma2-plugin-extensions-suptv" "6.0-r0" ;;
    12) exit ;;
    *)  echo -e "\033[0;31mInvalid option\033[0m"; exit ;;
esac