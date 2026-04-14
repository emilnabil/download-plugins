#!/bin/sh
##command=wget -q "--no-check-certificate" https://github.com/emilnabil/download-plugins/raw/refs/heads/main/Skin-MX_Maestra_Black_weather/Skin-MX_Maestra_Black_weather.sh -O - | /bin/sh
#######################
PYTHON_VERSION=$(python -c"import platform; print(platform.python_version())")

set -e

echo "Removing old package..."
rm -rf /usr/share/enigma2/MX_Maestra_Black_weather

echo "Installing plugin..."
cd /tmp || { echo "Failed to enter /tmp"; exit 1; }

if command -v wget >/dev/null 2>&1; then
    echo "Downloading using wget..."
    wget -q --no-check-certificate -O usr/share/enigma2/MX_Maestra_Black_weather.tar.gz "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/usr/share/enigma2/MX_Maestra_Black_weather/usr/share/enigma2/MX_Maestra_Black_weather.tar.gz"
elif command -v curl >/dev/null 2>&1; then
    echo "Downloading using curl..."
    curl -k -L -o usr/share/enigma2/MX_Maestra_Black_weather.tar.gz "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/usr/share/enigma2/MX_Maestra_Black_weather/usr/share/enigma2/MX_Maestra_Black_weather.gz"
else
    echo "Error: neither wget nor curl is available to download the file."
    exit 1
fi

if [ ! -f usr/share/enigma2/MX_Maestra_Black_weather.tar.gz ]; then
    echo "Error: failed to download the file."
    exit 1
fi

echo "Extracting..."
tar -xzf usr/share/enigma2/MX_Maestra_Black_weather.tar.gz -C /
sleep 1

echo "Cleaning temporary files..."
rm -f usr/share/enigma2/MX_Maestra_Black_weather.tar.gz

echo "Installation successful."
exit 0
