#!/bin/bash
#
### Command=curl -kLs https://github.com/emilnabil/download-plugins/raw/refs/heads/main/spinners/spinner-collar.sh | sh
#####################

echo "Removing previous spinners ..."
sleep 2

rm -rf /usr/share/enigma2/spinner/* >/dev/null 2>&1
echo "Spinner removed."

# Download and extract the new spinner
cd /tmp || exit 1

echo "Downloading spinner..."
curl -k -L -m 60 "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/spinners/spinner-collar.tar.gz" -o /tmp/spinner-collar.tar.gz

if [ -f /tmp/spinner-collar.tar.gz ]; then
    echo "Installing..."
    tar -xzf /tmp/spinner-collar.tar.gz -C /
    echo ""
    sleep 1
    rm -f /tmp/spinner-collar.tar.gz
    echo "Installation complete."
else
    echo "Download failed!"
fi

sleep 2
exit 0






