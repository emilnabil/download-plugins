#!/bin/sh

# Check and install wget
echo "> Checking and installing wget if not present..."

if [ -f /etc/apt/apt.conf ]; then
    apt-get update > /dev/null 2>&1
    apt-get install wget -y > /dev/null 2>&1
elif [ -f /etc/opkg/opkg.conf ]; then
    opkg update > /dev/null 2>&1
    opkg install wget > /dev/null 2>&1
else
    echo "> Package manager not recognized, please install wget manually."
fi

# Final check
if command -v wget > /dev/null 2>&1; then
    echo "> wget is installed successfully."
else
    echo "> Failed to install wget."
fi

exit

