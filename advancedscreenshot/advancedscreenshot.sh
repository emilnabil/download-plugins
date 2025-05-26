#!/bin/sh
echo "install plugin advancedscreenshot"
cd /tmp
curl  -k -Lbk -m 55532 -m 555104 "https://drive.google.com/uc?id=1GUJn8CUhv3KfmeqS-QJXvvCqy5Q79Pqz&export=download" > /tmp/enigma2-plugin-extensions-advancedscreenshot_1.2_all.ipk
sleep 1
echo "install plugin...."
cd /tmp
opkg install /tmp/enigma2-plugin-extensions-advancedscreenshot_1.2_all.ipk
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
sleep 1
rm /tmp/enigma2-plugin-extensions-advancedscreenshot_1.2_all.ipk
sleep 2
exit
