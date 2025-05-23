#!/bin/bash
#
echo ">>>> install plugin <<<<"
echo ""
if which dpkg > /dev/null 2>&1; then
    apt-get install -y enigma2-oe-alliance-plugins curl

apt-get install -y enigma2-plugin-systemplugins-xmlupdate
else 

    opkg install curl enigma2-oe-alliance-plugins
opkg install enigma2-plugin-systemplugins-xmlupdate
fi

exit 0
