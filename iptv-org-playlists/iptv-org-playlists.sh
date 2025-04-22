echo ""
opkg install curl
sleep 2
cd /tmp
curl  -k -Lbk -m 55532 -m 555104 "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/iptv-org-playlists/iptv-org-playlists.tar.gz" > /tmp/iptv-org-playlists.tar.gz
sleep 1
echo "installing ...."
cd /tmp
tar -xzf iptv-org-playlists.tar.gz  -C /
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
sleep 1
cd
rm -f /tmp/iptv-org-playlists.tar.gz
echo "OK"
echo " UPLOADED SCRIPT BY EMIL_NABIL "
sleep 4
exit 0
