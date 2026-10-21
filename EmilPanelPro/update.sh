#!/bin/bash

TMPPATH="/tmp/EmilPanelPro"
PLUGIN_ARCHIVE="EmilPanelPro.tar.gz"
STATUS=""
OSTYPE=""
INSTALLER=""
PYTHON_CMD=""
PYTHON=""
PYTHON_VERSION=""

echo "========================================"
echo "   EmilPanelPro Full Installer"
echo "========================================"

if [ -f /etc/apt/sources.list ] || [ -f /etc/apt/sources.list.d/dreambox.list ] || [ -d /etc/apt/apt.conf.d ]; then
    STATUS="/var/lib/dpkg/status"
    OSTYPE="DreamOS"
    INSTALLER="apt-get"
    echo "Detected: DreamOS (Debian based)"
elif [ -f /etc/opkg/opkg.conf ]; then
    STATUS="/var/lib/opkg/status"
    OSTYPE="OpenSource"
    INSTALLER="opkg"
    echo "Detected: OpenSource Enigma2"
else
    echo "Unsupported package system. Trying fallback..."
    if command -v opkg >/dev/null 2>&1; then
        STATUS="/var/lib/opkg/status"
        OSTYPE="OpenSource"
        INSTALLER="opkg"
        echo "Using opkg as package manager"
    elif command -v apt-get >/dev/null 2>&1; then
        STATUS="/var/lib/dpkg/status"
        OSTYPE="DreamOS"
        INSTALLER="apt-get"
        echo "Using apt-get as package manager"
    else
        echo "No supported package manager found!"
        exit 1
    fi
fi

echo "Checking Python version..."
if command -v python3 >/dev/null 2>&1; then
    PYTHON_CMD="python3"
    PYTHON_VERSION=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>/dev/null)
    PYTHON="py3"
    echo "Python 3 detected (version $PYTHON_VERSION)"
elif command -v python >/dev/null 2>&1; then
    PYTHON_CMD="python"
    PYTHON_VERSION_FULL=$(python -c "import sys; print(sys.version)" 2>/dev/null)
    if echo "$PYTHON_VERSION_FULL" | grep -q "2\."; then
        PYTHON="py2"
        PYTHON_VERSION=$(python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>/dev/null)
        echo "Python 2 detected (version $PYTHON_VERSION)"
    else
        PYTHON="py3"
        PYTHON_VERSION=$(python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>/dev/null)
        echo "Python 3 detected (version $PYTHON_VERSION) using 'python' command"
    fi
else
    echo "Python is not installed."
    exit 1
fi

echo "Removing old versions..."
for path in "/usr/lib/enigma2/python/Plugins/Extensions/EmilStore" \
            "/usr/lib64/enigma2/python/Plugins/Extensions/EmilStore"; do
    [ -d "$path" ] && rm -rf "$path"
done
echo "Old versions removed"

echo "Downloading and installing plugin..."
rm -rf "$TMPPATH"
mkdir -p "$TMPPATH"
cd "$TMPPATH" || exit 1

if [ "$OSTYPE" = "DreamOS" ]; then
    URL="https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilStore/Dreambox/EmilPanelPro.tar.gz"
    echo "Using DreamOS version"
else
    if [ "$PYTHON" = "py2" ]; then
        URL="https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilStore/OpenSurce/Py2/EmilPanelPro.tar.gz"
        echo "Using OpenSource Python 2 version"
    else
        URL="https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilStore/OpenSurce/Py3/EmilPanelPro.tar.gz"
        echo "Using OpenSource Python 3 version"
    fi
fi

echo "Downloading from: $URL"
wget -q --show-progress "$URL" -O "$PLUGIN_ARCHIVE" || {
    echo "Download failed!"
    cd / ; rm -rf "$TMPPATH"
    exit 1
}

echo "Extracting files..."
tar -xzf "$PLUGIN_ARCHIVE" -C / || {
    echo "Extraction failed!"
    cd / ; rm -rf "$TMPPATH"
    exit 1
}

if [ "$OSTYPE" = "DreamOS" ] && [ -d "/usr/lib64/enigma2/python/Plugins" ]; then
    echo "Copying files to 64-bit path..."
    mkdir -p "/usr/lib64/enigma2/python/Plugins/Extensions"
    cp -r "/usr/lib/enigma2/python/Plugins/Extensions/EmilStore" "/usr/lib64/enigma2/python/Plugins/Extensions/" 2>/dev/null || true
fi

cd /
rm -rf "$TMPPATH"
sync

echo "========================================"
echo "EmilPanelPro INSTALLED SUCCESSFULLY!"
echo "========================================"
echo "Plugin: EmilPanelPro"
echo "System: $OSTYPE"
echo "Python: $PYTHON_CMD $PYTHON_VERSION"
echo "Path: /usr/lib/enigma2/python/Plugins/Extensions/EmilStore"
echo "----------------------------------------"
echo "Restarting Enigma2 in 3 seconds..."
sleep 3

if [ "$OSTYPE" = "DreamOS" ]; then
    if command -v systemctl >/dev/null 2>&1; then
        systemctl restart enigma2
    else
        echo "Restarting using init..."
        init 4 && sleep 2 && init 3
    fi
else
    echo "Restarting Enigma2..."
    killall -9 enigma2
fi

exit 0
