echo ""
opkg install curl
sleep 2
cd /tmp
curl  -k -Lbk -m 55532 -m 555104 "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/auto-dcw-key-add/auto-dcw-key-add.tar.gz" > /tmp/auto-dcw-key-add.tar.gz
sleep 1
echo "installing ...."
cd /tmp
tar -xzf auto-dcw-key-add.tar.gz  -C /
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
rm -f /tmp/auto-dcw-key-add.tar.gz
echo "OK"
echo " UPLOADED SCRIPT BY EMIL_NABIL "
sleep 4
exit 0
