#!/bin/bash

# Detect OS and package manager
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

cd /tmp || exit 1

# Install necessary packages if not already installed
for cmd in wget curl unzip; do
    if ! command -v "$cmd" > /dev/null 2>&1; then
        echo "$cmd not found, installing..."
        if ! $INSTALL "$cmd"; then
            echo "Failed to install $cmd"
            exit 1
        fi
    fi
done

# Fetch the latest zip file from GitHub
echo "Fetching latest settings from GitHub..."
latest_file=$(curl -s https://api.github.com/repos/morpheus883/enigma2-zipped/contents/ | grep -o 'E2_Morph883_0.8W-13E-19.2E-28.2E_[^"]*\.zip' | sort -r | head -n1)

if [ -z "$latest_file" ]; then
    echo "No matching .zip file found."
    exit 1
fi

# Download the latest file
echo "Downloading latest file: $latest_file"
if ! wget -q "https://github.com/morpheus883/enigma2-zipped/raw/master/$latest_file" -O "/tmp/$latest_file"; then
    echo "Download failed."
    exit 1
fi

# Backup current settings
backup_dir="/etc/enigma2_backup_$(date +%Y%m%d_%H%M%S)"
echo "Creating backup of current settings in $backup_dir"
mkdir -p "$backup_dir"
cp -r /etc/enigma2/* "$backup_dir/"

# Clean up old settings
echo "Cleaning old settings..."
rm -rf /etc/enigma2/*.tv
rm -rf /etc/enigma2/*.radio

# Extract and copy the new settings
extract_dir="/tmp/extracted_settings"
mkdir -p "$extract_dir"
if ! unzip -q "/tmp/$latest_file" -d "$extract_dir"; then
    echo "Failed to unzip $latest_file"
    # Restore backup if extraction fails
    echo "Restoring from backup..."
    cp -rf "$backup_dir"/* /etc/enigma2/
    exit 1
fi

# Copy new settings
if ! cp -rf "$extract_dir"/"${latest_file%.zip}"/* /etc/enigma2/; then
    echo "Failed to copy files to /etc/enigma2/"
    # Restore backup if copy fails
    echo "Restoring from backup..."
    cp -rf "$backup_dir"/* /etc/enigma2/
    exit 1
fi

echo "Files copied to /etc/enigma2/ successfully."

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




