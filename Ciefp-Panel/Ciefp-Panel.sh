#!/bin/bash
##setup command=wget -q "--no-check-certificate" https://github.com/emilnabil/download-plugins/raw/refs/heads/main/Ciefp-Panel/Ciefp-Panel.sh -O - | /bin/sh

######### Only This 2 lines to edit with new version ######
version='1.1'
changelog='\nFix little bugs\nUpdated Picons List'
TMPPATH=/tmp/CiefpsettingsPanel
if [ ! -d /usr/lib64 ]; then
PLUGINPATH=/usr/lib/enigma2/python/Plugins/Extensions/CiefpsettingsPanel
else
PLUGINPATH=/usr/lib64/enigma2/python/Plugins/Extensions/CiefpsettingsPanel
fi
if [ -f /var/lib/dpkg/status ]; then
STATUS="/var/lib/dpkg/status"
OSTYPE="DreamOs"
else
STATUS="/var/lib/opkg/status"
OSTYPE="Dream"
fi
if python --version 2>&1 | grep -q '^Python 3\.'; then
echo "You have Python3 image"
PYTHON="PY3"
Packagesix="python3-six"
Packagerequests="python3-requests"
else
echo "You have Python2 image"
PYTHON="PY2"
Packagerequests="python-requests"
fi
if [ "$PYTHON" = "PY3" ] && ! grep -qs "Package: $Packagesix" "$STATUS"; then
opkg update && opkg install python3-six
fi
if ! grep -qs "Package: $Packagerequests" "$STATUS"; then
echo "Need to install $Packagerequests"
if [ "$OSTYPE" = "DreamOs" ]; then
apt-get update && apt-get install "$Packagerequests" -y
else
opkg update && opkg install "$Packagerequests"
fi
fi
[ -d "$TMPPATH" ] && rm -rf "$TMPPATH"
[ -d "$PLUGINPATH" ] && rm -rf "$PLUGINPATH"
mkdir -p "$TMPPATH"
cd "$TMPPATH" || exit 1
if [ "$OSTYPE" = "DreamOs" ]; then
echo "# Your image is OE2.5/2.6 #"
else
echo "# Your image is OE2.0 #"
fi
PLUGIN_URL="https://github.com/emilnabil/download-plugins/raw/refs/heads/main/Ciefp-Panel"
if [ "$PYTHON" = "PY3" ]; then
wget "$PLUGIN_URL/py3/Ciefp-Panel.tar.gz"
else
wget "$PLUGIN_URL/py2/Ciefp-Panel.tar.gz"
fi
tar -xzf Ciefp-Panel.tar.gz
cp -r "Ciefp-Panel/usr" "/"
sync
echo "#########################################################"
echo "#    Ciefp-Panel INSTALLED SUCCESSFULLY          #"
echo "#                  developed by ciefp                   #"
echo "#                   Big thanks Qu4k3                    #"
echo "#                  .::ciefpsettings::.                  #"
echo "#                  https://Sat-Club.EU                  #"
echo "#########################################################"
if [ ! -d /usr/lib64 ]; then
PLUGINPATH=/usr/lib/enigma2/python/Plugins/Extensions/CiefpsettingsPanel
RESTART_CMD="killall -9 enigma2"
else
PLUGINPATH=/usr/lib64/enigma2/python/Plugins/Extensions/CiefpsettingsPanel
RESTART_CMD="systemctl restart enigma2"
fi
...
sync
echo "#########################################################"
echo "#    Ciefp-Panel INSTALLED SUCCESSFULLY          #"
echo "#                  developed by ciefp                   #"
echo "#                   Big thanks Qu4k3                    #"
echo "#                  .::ciefpsettings::.                  #"
echo "#                  https://Sat-Club.EU                  #"
echo "#########################################################"
echo "#           Your device will RESTART now                #"
echo "#########################################################"
sleep 5
$RESTART_CMD
exit 0



