#!/bin/sh
echo "install plugin "
cd /tmp
curl  -k -Lbk -m 55532 -m 555104 "https://drive.google.com/uc?id=1MlV0YlwC-6cumsE1IXn-5Dz-aCfx8Uix&export=download" > /tmp/cccaminfo_py2.ipk
sleep 1
echo "install plugin...."
cd /tmp
opkg install /tmp/cccaminfo_py2.ipk
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
sleep 1
rm /tmp/cccaminfo_py2.ipk
sleep 2
exit
