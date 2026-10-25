#!/bin/sh
echo "install TvMadXtream"
sleep 1
cd /tmp
curl  -k -Lbk -m 55532 -m 555104 "https://drive.google.com/uc?id=1vYlb0Xu5KNy1Fmh36vypGh-RVO-P8uVf&export=download" > /tmp/enigma2-plugin-extensions-tvmadxtream_all.ipk
sleep 1
echo "install ...."
cd /tmp
opkg install /tmp/enigma2-plugin-extensions-tvmadxtream_all.ipk
echo ""
echo ""
echo ""
echo ""
echo ""
sleep 1
rm /tmp/enigma2-plugin-extensions-tvmadxtream_all.ipk
sleep 2
killall -9 enigma2
exit
