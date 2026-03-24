#!/bin/sh
##command=wget -q "--no-check-certificate" https://github.com/emilnabil/download-plugins/raw/refs/heads/main/AutomaticVolumeAdjustment/AutomaticVolumeAdjustment.sh -O - | /bin/sh
#########################################
echo "install plugin"
cd /tmp
if command -v wget >/dev/null 2>&1; then
    wget -q --no-check-certificate -O AutomaticVolumeAdjustment.tar.gz "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/AutomaticVolumeAdjustment/AutomaticVolumeAdjustment.tar.gz"
else
    curl -k -L -o AutomaticVolumeAdjustment.tar.gz "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/AutomaticVolumeAdjustment/AutomaticVolumeAdjustment.tar.gz"
fi
sleep 1
echo "install plugin...."
cd /tmp
tar -xzf AutomaticVolumeAdjustment.tar.gz -C /
sleep 2
rm -f AutomaticVolumeAdjustment.tar.gz
sleep 2
exit
