#!/bin/bash
######################################################################################
## Command=wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/setpicon/installer.sh -O - | /bin/sh
##
###########################################
###########################################

# My config script #
MY_TAR_PY2="enigma2-plugin-extensions-setpicon_v2.0_all.ipk"
MY_TAR_PY3="enigma2-plugin-extensions-setpicon_v3.0_all.ipk"
MY_URL="https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/setpicon"
PYTHON_VERSION=$(python -c 'import sys; print(sys.version_info[0])')

######################################################################################
MY_EM='============================================================================================================'

# Remove Old Plugin
echo "   >>>>   Removing old version..."
rm -rf /usr/lib/enigma2/python/Plugins/Extensions/SetPicon

echo "============================================================================================================================"
echo " DOWNLOAD AND INSTALL PLUGIN "
echo "   Installing plugin, please wait..."

cd /tmp || exit 1
set -e

if [ "$PYTHON_VERSION" -eq 3 ]; then
    PLUGIN_TAR="$MY_TAR_PY3"
else
    PLUGIN_TAR="$MY_TAR_PY2"
fi

wget "$MY_URL/$PLUGIN_TAR"
sleep 1
tar xzvpf "/tmp/$PLUGIN_TAR" -C /
rm -rf "/tmp/$PLUGIN_TAR"

echo "================================="
set +e

if [ $? -eq 0 ]; then
    echo ">>>>  SUCCESSFULLY INSTALLED <<<<"
fi

echo "********************************************************************************"
echo "   UPLOADED BY  >>>>   EMIL_NABIL " 
sleep 4                        
echo "$MY_EM"
echo "**********************************************************************************"

exit 0










