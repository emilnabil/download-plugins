#!/bin/bash
##Command=wget --no-check-certificate -O - https://github.com/emilnabil/download-plugins/raw/refs/heads/main/GeminiPatcher/geminipatcher.sh -O - | /bin/sh
############################
echo "Removing previous version ..."
sleep 2

if [ -d /usr/lib/enigma2/python/Plugins/Extensions/GeminiPatcher ]; then
    rm -rf /usr/lib/enigma2/python/Plugins/Extensions/GeminiPatcher >/dev/null 2>&1
    echo "Package removed."
else
    echo "You do not have previous version"
fi

echo ""
opkg install curl
sleep 2

cd /tmp || exit
curl -k -L "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/GeminiPatcher/GeminiPatcher.tar.gz" -o /tmp/GeminiPatcher.tar.gz
sleep 2

echo "Installing ...."
tar -xzf /tmp/GeminiPatcher.tar.gz -C /
echo ""
echo ""

sleep 1
rm -f /tmp/GeminiPatcher.tar.gz
echo " Uploaded By Emil Nabil"
sleep 2
exit 0












