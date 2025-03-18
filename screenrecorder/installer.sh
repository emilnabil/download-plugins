#!/bin/bash
######################################################################################
## Command=wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/screenrecorder/installer.sh -O - | /bin/sh
##
###########################################
###########################################

# My config script #
PLUGIN_IPK="enigma2-plugin-extensions-screenrecorder_1.0_all.ipk"
MY_URL="https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/screenrecorder"

######################################################################################

# Remove Old Plugin
echo ">>> Removing old version..."
opkg remove enigma2-plugin-extensions-screenrecorder 
rm -rf /usr/lib/enigma2/python/Plugins/Extensions/ScreenRecorder

echo ">>> Downloading and Installing Plugin..."

cd /tmp || exit 1
set -e

wget "$MY_URL/$PLUGIN_IPK" || exit 1
opkg install --force-reinstall --force-depends "/tmp/$PLUGIN_IPK"
install_status=$?
rm -f "/tmp/$PLUGIN_IPK"

set +e
if [ $install_status -eq 0 ]; then
    echo ">>>> SUCCESSFULLY INSTALLED <<<<"
else
    echo ">>>> INSTALLATION FAILED <<<<"
    exit 1
fi

echo ">>> Uploaded by: EMIL_NABIL"
exit 0

