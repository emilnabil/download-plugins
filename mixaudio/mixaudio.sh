#!/bin/bash

version="1.0"

ipkurl_arm="https://github.com/Najar1991/MixAudio_ARM/raw/refs/heads/main/MixAudio.ipk"
ipkurl_mips="https://github.com/Najar1991/MixAudio_mipsel/raw/refs/heads/main/MixAudio.ipk"
ipkurl_aarch="https://github.com/Najar1991/MixAudio_aarch64/raw/refs/heads/main/MixAudio.ipk"

echo ""
echo "MixAudio Installer v$version"
echo "============================"

if [ "$EUID" -ne 0 ]; then
    echo "Error: Please run as root!"
    exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
    echo ""
    echo "Python3 is not installed!"
    echo "This plugin requires Python 3.13.x ONLY"
    echo ""
    exit 1
fi

PY_FULL=$(python3 -c "import sys; print(sys.version.split()[0])")
PY_MAJOR_MINOR=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")

if [ "$PY_MAJOR_MINOR" != "3.13" ]; then
    echo ""
    echo "Unsupported Python version detected: $PY_FULL"
    echo "This plugin works ONLY with Python 3.13.x"
    echo ""
    exit 1
fi

echo "Python $PY_FULL detected (Supported)"
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

tmp_dir="/tmp/mixaudio-install"
mkdir -p "$tmp_dir"
cd "$tmp_dir" || exit 1

if echo "$ARCH" | grep -qi "mips"; then
    echo "Detected architecture: MIPS"
    wget --no-check-certificate -q --show-progress "$ipkurl_mips" -O MixAudio.ipk

elif echo "$ARCH" | grep -qi "armv7l"; then
    echo "Detected architecture: armv7l"
    wget --no-check-certificate -q --show-progress "$ipkurl_arm" -O MixAudio.ipk

elif echo "$ARCH" | grep -qi "aarch64"; then
    echo "Detected architecture: aarch64"
    wget --no-check-certificate -q --show-progress "$ipkurl_aarch" -O MixAudio.ipk

else
    echo "Unsupported architecture: $ARCH"
    rm -rf "$tmp_dir"
    exit 1
fi

if [ ! -f MixAudio.ipk ] || [ ! -s MixAudio.ipk ]; then
    echo "Download failed"
    rm -rf "$tmp_dir"
    exit 1
fi

echo "Installing MixAudio..."
opkg install --force-overwrite ./MixAudio.ipk

if [ $? -eq 0 ]; then
    echo ""
    echo "MixAudio v$version installed successfully"
    echo "Restarting Enigma2 in 3 seconds..."
    sleep 3
    killall -9 enigma2
else
    echo "Installation failed"
    rm -rf "$tmp_dir"
    exit 1
fi

rm -rf "$tmp_dir"
exit 0


