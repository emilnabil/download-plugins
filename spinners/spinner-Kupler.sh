#!/bin/bash
#
###Command=curl -kLs https://github.com/emilnabil/download-plugins/raw/refs/heads/main/spinners/spinner-Kupler.sh|sh
#####################
echo "Removing previous spinners ..."
sleep 2

    rm -rf /usr/share/enigma2/spinner/* > /dev/null 2>&1
    
    echo 'spinner removed.'

# Download and extract the spinner
cd /tmp || exit
curl -k -Lbk -m 55532 -m 555104 "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/spinners/spinner-Kupler.tar.gz" -o /tmp/spinner-Kupler.tar.gz
sleep 1
echo "Installing ...."
tar -xzf /tmp/spinner-Kupler.tar.gz -C /
echo ""
echo ""
sleep 1
rm -f /tmp/spinner-Kupler.tar.gz
sleep 2
exit 0






