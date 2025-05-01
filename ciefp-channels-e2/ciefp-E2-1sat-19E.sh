#!/bin/bash

if [ -f /etc/apt/apt.conf ]; then
    INSTALL="apt-get install -y"
    OPKGREMOVE="apt-get purge --auto-remove -y"
    CHECK_INSTALLED="dpkg -l"
    OS="DreamOS"
elif [ -f /etc/opkg/opkg.conf ]; then
    INSTALL="opkg install"
    OPKGREMOVE="opkg remove --force-depends"
    CHECK_INSTALLED="opkg list-installed"
    OS="Opensource"
else
    echo "Unsupported OS"
    exit 1
fi

cd /tmp

# Install necessary packages if not already installed
for cmd in wget curl unzip; do
    if ! command -v $cmd > /dev/null 2>&1; then
        echo "$cmd not found, installing..."
        $INSTALL $cmd
        if [ $? -ne 0 ]; then
            echo "Failed to install $cmd"
            exit 1
        fi
    fi
done

# Fetch the page content
page_content=$(curl -s "https://github.com/ciefp/ciefpsettings-enigma2-zipped/tree/master")
if [ $? -ne 0 ] || [ -z "$page_content" ]; then
    echo "Failed to fetch page content."
    exit 1
fi

# Extract .zip filenames
filenames=$(echo "$page_content" | grep -o 'ciefp-E2-1sat-19E-[^"]*\.zip')
if [ -z "$filenames" ]; then
    echo "No matching .zip file found."
    exit 1
fi

# Get the latest file
latest_file=$(echo "$filenames" | sort -r | head -n1)

# Download the latest file
echo "Downloading latest file: $latest_file"
wget -q "https://raw.githubusercontent.com/ciefp/ciefpsettings-enigma2-zipped/master/$latest_file" -O "/tmp/$latest_file"
if [ $? -ne 0 ]; then
    echo "Download failed."
    exit 1
fi

# Extract and copy the new settings
extract_dir="/tmp/extracted_settings"
mkdir -p "$extract_dir"
unzip "/tmp/$latest_file" -d "$extract_dir"
if [ $? -ne 0 ]; then
    echo "Failed to unzip $latest_file"
    exit 1
fi

cp -rf "$extract_dir"/"${latest_file%.zip}"/* /etc/enigma2/

if [ $? -eq 0 ]; then
    echo "Files copied to /etc/enigma2/ successfully."
else
    echo "Failed to copy files to /etc/enigma2/"
    exit 1
fi

# Clean up temporary files
echo "Cleaning up temporary files..."
rm -rf "$extract_dir"
rm -f "/tmp/$latest_file"

echo "   UPLOADED BY  >>>>   EMIL_NABIL "

# Restart GUI
sleep 3
echo 'RESTARTING GUI ...'
sync
sleep 2
if command -v systemctl > /dev/null 2>&1; then
    systemctl restart enigma2
else
    killall -9 enigma2
fi

exit 0






