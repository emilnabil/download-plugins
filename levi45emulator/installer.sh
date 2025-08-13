echo " Download And Install Plugin Ajpanel "
TEMPATH=/tmp
OPKGINSTALL="opkg install --force-overwrite"
MY_IPK="enigma2-plugin-extensions-ajpanel_all.ipk"
MY_DEB="enigma2-plugin-extensions-ajpanel_all.deb"
MY_URL="http://dreambox4u.com/emilnabil237/plugins/ajpanel"
if [ -f /etc/apt/apt.conf ] ; then
STATUS='/var/lib/dpkg/status'
OS='DreamOS'
elif [ -f /etc/opkg/opkg.conf ] ; then
STATUS='/var/lib/opkg/status'
OS='Opensource'
fi
echo " remove old version "
opkg remove enigma2-plugin-extensions-ajpanel 
rm -rf /usr/lib/enigma2/python/Plugins/Extensions/AJPan
echo ""
cd /tmp
set -e
if which dpkg > /dev/null 2>&1; then
wget "http://dreambox4u.com/emilnabil237/plugins/ajpanel/enigma2-plugin-extensions-ajpanel_all.deb"
dpkg -i --force-overwrite enigma2-plugin-extensions-ajpanel_all.deb; apt-get install -f -y
wait
rm -f enigma2-plugin-extensions-ajpanel_all.deb
else
wget "http://dreambox4u.com/emilnabil237/plugins/ajpanel/enigma2-plugin-extensions-ajpanel_all.ipk"
opkg install --force-overwrite enigma2-plugin-extensions-ajpanel_all.ipk
wait
rm -f enigma2-plugin-extensions-ajpanel_all.ipk
fi
echo "================================="
set +e
cd ..
echo "********************************************************************************"
echo "   UPLOADED BY  >>>>   EMIL_NABIL "
sleep 4;
echo "#                Restart Enigma2 GUI                    #"
echo "#########################################################"
sleep 2
if [ $OS = 'DreamOS' ]; then
systemctl restart enigma2
else
killall -9 enigma2
fi
exit 0
