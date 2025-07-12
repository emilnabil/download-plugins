#!/bin/sh

CONFIG_URL="https://raw.githubusercontent.com/ciefp/astra.conf/main/astra.conf"
DEST_FILE="/etc/astra/astra.conf"

echo "> Downloading Astra config file, please wait..."
sleep 2

# تأكد من وجود مجلد astra
mkdir -p /etc/astra

# تحميل الملف
if wget --no-check-certificate -qO "$DEST_FILE" "$CONFIG_URL"; then
    echo "> Astra config file downloaded successfully."
else
    echo "> Failed to download Astra config file!"
    exit 1
fi

sleep 2
exit 0
