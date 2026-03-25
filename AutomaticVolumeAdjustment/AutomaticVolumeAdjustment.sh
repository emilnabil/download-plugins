#!/bin/sh
##command=wget -q "--no-check-certificate" https://github.com/emilnabil/download-plugins/raw/refs/heads/main/AutomaticVolumeAdjustment/AutomaticVolumeAdjustment.sh -O - | /bin/sh
#########################################
echo "install plugin"

cd /tmp
if [ -f /etc/openpli-version ] || [ -f /etc/openpli-release ] || grep -q "openpli" /etc/issue 2>/dev/null; then
    IMAGE_TYPE="openpli"
    echo "Detected OpenPLI image"
    PLUGIN_URL="https://github.com/emilnabil/download-plugins/raw/refs/heads/main/AutomaticVolumeAdjustment/AutomaticVolumeAdjustment-pli.tar.gz"
else
    IMAGE_TYPE="other"
    echo "Detected other image"
    PLUGIN_URL="https://github.com/emilnabil/download-plugins/raw/refs/heads/main/AutomaticVolumeAdjustment/AutomaticVolumeAdjustment.tar.gz"
fi

if command -v wget >/dev/null 2>&1; then
    wget -q --no-check-certificate -O AutomaticVolumeAdjustment.tar.gz "$PLUGIN_URL"
else
    curl -k -L -o AutomaticVolumeAdjustment.tar.gz "$PLUGIN_URL"
fi

if [ $? -eq 0 ] && [ -f AutomaticVolumeAdjustment.tar.gz ]; then
    echo "Download successful for $IMAGE_TYPE image"
    sleep 1
    echo "Installing plugin...."
    cd /tmp
    tar -xzf AutomaticVolumeAdjustment.tar.gz -C /
    sleep 2
    rm -f AutomaticVolumeAdjustment.tar.gz
    echo "Plugin installed successfully"
else
    echo "Download failed!"
    exit 1
fi

sleep 2
exit
