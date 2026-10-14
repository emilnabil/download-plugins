#!/bin/sh
###wget --no-check-certificate -O - https://github.com/emilnabil/download-plugins/raw/refs/heads/main/AlternativeSoftcamManager.tar.gz/AlternativeSoftcamManager.sh | /bin/sh
###################

echo "install AlternativeSoftcamManager"
sleep 2

cd /tmp

curl -k -L -o /tmp/AlternativeSoftcamManager.tar.gz "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/AlternativeSoftcamManager/AlternativeSoftcamManager.tar.gz"

sleep 1
echo "installing ...."

cd /tmp

if [ -f /tmp/AlternativeSoftcamManager.tar.gz ]; then
    tar -xzf AlternativeSoftcamManager.tar.gz -C /
    echo ""
    echo "OK"
else
    echo "ERROR: Download failed!"
    exit 1
fi

sleep 1
cd
rm -f /tmp/AlternativeSoftcamManager.tar.gz

echo " UPLOADED BY EMIL_NABIL"
sleep 4
echo ""
echo ""
exit







