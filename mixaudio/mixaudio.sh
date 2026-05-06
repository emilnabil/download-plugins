#!/bin/bash
##Command=wget https://github.com/emilnabil/download-plugins/raw/refs/heads/main/mixaudio/mixaudio.sh -O - | /bin/sh
##################################

version="1.2"
base_url="https://github.com/Najar1991/MixAudio_All/raw/refs/heads/main"

ipkurl_arm="$base_url/MixAudio_arm.ipk"
ipkurl_mips="$base_url/MixAudio_mipsel.ipk"
ipkurl_aarch="$base_url/MixAudio_aarch64.ipk"

echo ""
echo "MixAudio Installer v$version"
echo "============================"

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: Please run as root!"
    exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
    echo ""
    echo "Error: Python3 is not installed!"
    echo "This plugin requires Python 3.13.x"
    echo "Please upgrade your image and try again."
    echo ""
    exit 1
fi

PY_FULL=$(python3 -c "import sys; print(sys.version.split()[0])")
PY_MAJOR_MINOR=$(python3 -c "import sys; print(str(sys.version_info.major) + '.' + str(sys.version_info.minor))")

if [ "$PY_MAJOR_MINOR" != "3.13" ]; then
    echo ""
    echo "Error: Unsupported Python version: $PY_FULL"
    echo "This plugin requires Python 3.13.x ONLY"
    echo "The plugin uses compiled .so files for Python 3.13"
    echo "Please upgrade your Enigma2 image and try again."
    echo ""
    exit 1
fi

echo "Python $PY_FULL detected (OK)"
echo ""

echo "Checking for previous MixAudio..."
if opkg list-installed | grep -q "enigma2-plugin-extensions-mixaudio"; then
    echo "Previous MixAudio found - removing..."
    opkg remove enigma2-plugin-extensions-mixaudio --force-depends
    rm -rf /usr/lib/enigma2/python/Plugins/Extensions/MixAudio
    echo "Previous version removed"
else
    echo "Fresh installation"
fi

echo "Updating package list..."
opkg update > /dev/null 2>&1

install_if_missing() {
    PKG=$1
    if ! opkg list-installed | grep -q "^$PKG "; then
        echo "Installing $PKG..."
        opkg install "$PKG" > /dev/null 2>&1
    else
        echo "$PKG already installed"
    fi
}

install_if_missing "ffmpeg"
install_if_missing "gstreamer1.0"
install_if_missing "gstreamer1.0-plugins-base"
install_if_missing "gstreamer1.0-plugins-good"
install_if_missing "gstreamer1.0-plugins-bad"
install_if_missing "gstreamer1.0-plugins-ugly"
install_if_missing "gstreamer1.0-libav"
install_if_missing "python3-core"
install_if_missing "python3-twisted"
install_if_missing "alsa-utils"

ARCH=$(uname -m)
IPK_FILE=""

tmp_dir="/tmp/mixaudio-install"
mkdir -p "$tmp_dir"
cd "$tmp_dir" || exit 1

if echo "$ARCH" | grep -qi "mips"; then
    echo "Detected architecture: MIPS"
    IPK_FILE="MixAudio_mipsel.ipk"
    wget --no-check-certificate -q "$ipkurl_mips" -O "$IPK_FILE"

elif echo "$ARCH" | grep -qi "aarch64"; then
    echo "Detected architecture: aarch64"
    IPK_FILE="MixAudio_aarch64.ipk"
    wget --no-check-certificate -q "$ipkurl_aarch" -O "$IPK_FILE"

elif echo "$ARCH" | grep -qiE "armv7l|armv8|arm"; then
    echo "Detected architecture: ARM"
    IPK_FILE="MixAudio_arm.ipk"
    wget --no-check-certificate -q "$ipkurl_arm" -O "$IPK_FILE"

else
    echo "Unsupported architecture: $ARCH"
    rm -rf "$tmp_dir"
    exit 1
fi

if [ ! -f "$IPK_FILE" ] || [ ! -s "$IPK_FILE" ]; then
    echo "Download failed - check your internet connection"
    rm -rf "$tmp_dir"
    exit 1
fi

echo "Installing MixAudio..."
opkg install --force-overwrite "./$IPK_FILE"
INSTALL_STATUS=$?

rm -rf "$tmp_dir"

if [ "$INSTALL_STATUS" -eq 0 ]; then
    echo ""
    echo "=============================="
    echo "MixAudio v$version installed successfully!"
    echo "Restarting Enigma2 in 3 seconds..."
    echo "=============================="
    sleep 3
    killall -9 enigma2
else
    echo "Installation failed"
    exit 1
fi

exit 0

