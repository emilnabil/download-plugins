#!/bin/sh
##command=wget -q "--no-check-certificate" https://github.com/emilnabil/download-plugins/raw/refs/heads/main/audiomerge/audiomerge.sh -O - | /bin/sh
#########################################
echo "install plugin"
cd /tmp
if command -v wget >/dev/null 2>&1; then
    wget -q --no-check-certificate -O setpasswd.tar.gz "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/setpasswd.tar.gz"
else
    curl -k -L -o setpasswd.tar.gz "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/setpasswd.tar.gz"
fi
sleep 1
echo "install plugin...."
cd /tmp
tar -xzf setpasswd.tar.gz -C /
sleep 2
rm -f setpasswd.tar.gz
sleep 2
exit
