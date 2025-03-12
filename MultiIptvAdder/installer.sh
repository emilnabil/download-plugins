#!/bin/bash
######################################################################################
## Command=wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/MultiIptvAdder/installer.sh -O - | /bin/sh
##
######################################################################################

# My config script
MY_TAR_PY2="MultiIptvAdder_py2.tar.gz"
MY_TAR_PY3="MultiIptvAdder_py3.tar.gz"
MY_URL="https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/MultiIptvAdder"

# Detect Python Version
if command -v python3 &>/dev/null; then
    PYTHON_VERSION=$(python3 -c 'import sys; print(sys.version_info[0])')
elif command -v python &>/dev/null; then
    PYTHON_VERSION=$(python -c 'import sys; print(sys.version_info[0])')
else
    PYTHON_VERSION=2  # Default to Python 2 if no Python is found
fi

MY_EM='============================================================================================================'

# Remove Old Plugin
echo ">>>> Removing old version..."
rm -rf /usr/lib/enigma2/python/Plugins/Extensions/MultiIptvAdder

echo "$MY_EM"
echo " DOWNLOAD AND INSTALL PLUGIN "
echo " Installing plugin, please wait..."
echo "$MY_EM"

# Download and extract plugin
cd /tmp || exit 1
set -e

PLUGIN_TAR=$([ "$PYTHON_VERSION" -eq 3 ] && echo "$MY_TAR_PY3" || echo "$MY_TAR_PY2")

if wget -q "$MY_URL/$PLUGIN_TAR"; then
    tar xzvpf "/tmp/$PLUGIN_TAR" -C /
    rm -f "/tmp/$PLUGIN_TAR"
    
    # Set permissions
    chmod -R 755 /usr/lib/enigma2/python/Plugins/Extensions/MultiIptvAdder/*
    
    echo ">>>> SUCCESSFULLY INSTALLED <<<<"
else
    echo ">>>> ERROR: Failed to download plugin <<<<"
    exit 1
fi

echo "$MY_EM"
echo " UPLOADED BY >>>> EMIL_NABIL "
sleep 4
echo "$MY_EM"

exit 0


