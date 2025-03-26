#!/bin/bash
######################################################################################
## Command=wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/screenrecorder/installer.sh -O - | /bin/sh
##
###########################################

# My config script #
PLUGIN_IPK="enigma2-plugin-extensions-screenrecorder_4.1.0_all.ipk"
MY_URL="https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/screenrecorder"

######################################################################################

echo ">>> Removing old version..."
opkg remove enigma2-plugin-extensions-screenrecorder 
rm -rf /usr/lib/enigma2/python/Plugins/Extensions/ScreenRecorder
sync

echo ">>> Downloading and Installing Plugin..."
cd /tmp || { echo "Failed to change directory to /tmp"; exit 1; }
set -e 
if wget "$MY_URL/$PLUGIN_IPK"; then
    opkg install --force-reinstall --force-depends "/tmp/$PLUGIN_IPK" && install_status=0 || install_status=1
else
    echo ">>>> DOWNLOAD FAILED <<<<"
    exit 1
fi

rm -f "/tmp/$PLUGIN_IPK"
set +e  
if [ $install_status -eq 0 ]; then
    echo ">>>> SUCCESSFULLY INSTALLED <<<<"
else
    echo ">>>> INSTALLATION FAILED <<<<"
    exit 1
fi

PACKAGES="mpg123 alsa-utils python3 ffmpeg enigma2"
install_needed=0

for pkg in $PACKAGES; do
    if ! opkg status "$pkg" | grep -q "Status: install"; then
        install_needed=1
        opkg install "$pkg"
    else
        echo "$pkg is already installed."
    fi
done

if [ $install_needed -eq 1 ]; then
    opkg update
fi

echo ">>> Uploaded by: EMIL_NABIL"
exit 0
