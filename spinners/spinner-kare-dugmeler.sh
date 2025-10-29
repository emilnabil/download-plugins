#!/bin/bash
#
### Command=curl -kLs https://github.com/emilnabil/download-plugins/raw/refs/heads/main/spinners/spinner-kare-dugmeler.sh | sh
#####################

echo "Removing previous spinners ..."
sleep 2

rm -rf /usr/share/enigma2/spinner/* >/dev/null 2>&1
echo "Spinner removed."

# Download and extract the new spinner
cd /tmp || exit 1

echo "Downloading spinner..."
curl -k -L -m 60 "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/spinners/spinner-kare-dugmeler.tar.gz" -o /tmp/spinner-kare-dugmeler.tar.gz

if [ -f /tmp/spinner-kare-dugmeler.tar.gz ]; then
    echo "Installing..."
    tar -xzf /tmp/spinner-kare-dugmeler.tar.gz -C /
    echo ""
    sleep 1
    rm -f /tmp/spinner-kare-dugmeler.tar.gz
    echo "Installation complete."
else
    echo "Download failed!"
fi

sleep 2
exit 0





