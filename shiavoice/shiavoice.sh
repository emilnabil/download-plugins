#!/bin/sh
 # 
echo "install skin"
sleep 2;
cd /tmp
curl  -k -Lbk -m 55532 -m 555104 "https://raw.githubusercontent.com/emil237/skins-enigma2/main/pli/shiavoice.tar.gz" > /tmp/shiavoice.tar.gz
sleep 1
echo "installing ...."
cd /tmp
tar -xzf shiavoice.tar.gz -C /
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
rm -f /tmp/shiavoice.tar.gz
echo "OK"
echo " UPLOADED BY EMIL_NABIL"
sleep 4
echo ""
echo ""
exit







