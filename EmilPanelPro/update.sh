#!/bin/bash
#################

TMPPATH="/tmp/EmilPanelPro"
PLUGIN_ARCHIVE="EmilPanelPro.tar.gz"
STATUS=""
OSTYPE=""
INSTALLER=""
PYTHON_CMD=""
PYTHON=""
PYTHON_VERSION="unknown"

echo "========================================"
echo "   EmilPanelPro Full Installer"
echo "========================================"

if [ -f /etc/opkg/opkg.conf ] && ! [ -d /etc/apt/apt.conf.d ]; then
    STATUS="/var/lib/opkg/status"
    OSTYPE="OpenSource"
    INSTALLER="opkg"
elif [ -f /etc/apt/sources.list ] || [ -d /etc/apt/apt.conf.d ] || [ -f /etc/apt/sources.list.d/dreambox.list ]; then
    STATUS="/var/lib/dpkg/status"
    OSTYPE="DreamOS"
    INSTALLER="apt-get"
else
    echo "Unsupported package system. Trying fallback..."
    if command -v opkg >/dev/null 2>&1; then
        STATUS="/var/lib/opkg/status"; OSTYPE="OpenSource"; INSTALLER="opkg"
    elif command -v apt-get >/dev/null 2>&1; then
        STATUS="/var/lib/dpkg/status"; OSTYPE="DreamOS"; INSTALLER="apt-get"
    else
        echo "No supported package manager found!"
        exit 1
    fi
fi
echo "Detected: $OSTYPE ($INSTALLER)"

if ! command -v wget >/dev/null 2>&1; then
    echo "wget not found, trying to install..."
    if [ "$INSTALLER" = "apt-get" ]; then
        apt-get update >/dev/null 2>&1 && apt-get install -y wget
    else
        opkg update >/dev/null 2>&1 && opkg install wget
    fi
    command -v wget >/dev/null 2>&1 || { echo "Cannot install wget, aborting."; exit 1; }
fi

echo "Checking Python version..."
if command -v python3 >/dev/null 2>&1; then
    PYTHON_CMD="python3"
    PYTHON_VERSION=$(python3 -c 'import sys; print("%d.%d" % sys.version_info[:2])' 2>/dev/null)
    PYTHON="py3"
    echo "Python 3 detected ($PYTHON_VERSION)"
elif command -v python >/dev/null 2>&1; then
    PYTHON_CMD="python"
    PYTHON_VERSION=$(python -c 'import sys; print("%d.%d" % sys.version_info[:2])' 2>/dev/null)
    case "$PYTHON_VERSION" in
        2.*) PYTHON="py2" ;;
        *)   PYTHON="py3" ;;
    esac
    echo "Python $PYTHON_VERSION detected (using '$PYTHON_CMD', target $PYTHON)"
else
    echo "Python is not installed."
    exit 1
fi

echo "Removing old versions..."
rm -rf "/usr/lib/enigma2/python/Plugins/Extensions/EmilStore"
rm -rf "/usr/lib64/enigma2/python/Plugins/Extensions/EmilStore"
echo "Old versions removed"

rm -rf "$TMPPATH"
mkdir -p "$TMPPATH" || { echo "Cannot create $TMPPATH"; exit 1; }
cd "$TMPPATH" || { echo "Cannot cd to $TMPPATH"; exit 1; }

BASE="https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilStore"
if [ "$OSTYPE" = "DreamOS" ]; then
    URL="$BASE/Dreambox/$PLUGIN_ARCHIVE"
    echo "Using DreamOS version"
elif [ "$PYTHON" = "py2" ]; then
    URL="$BASE/OpenSurce/Py2/$PLUGIN_ARCHIVE"
    echo "Using OpenSource Python 2 version"
else
    URL="$BASE/OpenSurce/Py3/$PLUGIN_ARCHIVE"
    echo "Using OpenSource Python 3 version"
fi

echo "Downloading from: $URL"
if ! wget --no-check-certificate -O "$PLUGIN_ARCHIVE" "$URL"; then
    echo "Download failed!"
    cd / || true; rm -rf "$TMPPATH"; exit 1
fi
[ -s "$PLUGIN_ARCHIVE" ] || { echo "Downloaded file is empty!"; cd / || true; rm -rf "$TMPPATH"; exit 1; }

echo "Verifying archive..."
if ! tar -tzf "$PLUGIN_ARCHIVE" >/dev/null 2>&1; then
    echo "Archive is corrupted!"
    cd / || true; rm -rf "$TMPPATH"; exit 1
fi

echo "Extracting files..."
if ! tar -xzf "$PLUGIN_ARCHIVE" -C /; then
    echo "Extraction failed!"
    cd / || true; rm -rf "$TMPPATH"; exit 1
fi

if [ "$OSTYPE" = "DreamOS" ] && [ -d "/usr/lib64/enigma2/python/Plugins" ]; then
    if [ -d "/usr/lib/enigma2/python/Plugins/Extensions/EmilStore" ]; then
        echo "Copying files to 64-bit path..."
        mkdir -p "/usr/lib64/enigma2/python/Plugins/Extensions"
        cp -r "/usr/lib/enigma2/python/Plugins/Extensions/EmilStore" \
              "/usr/lib64/enigma2/python/Plugins/Extensions/" || {
            echo "Warning: copy to 64-bit path failed (non-fatal)"
        }
    fi
fi

cd / || true
rm -rf "$TMPPATH"
sync

if [ ! -d "/usr/lib/enigma2/python/Plugins/Extensions/EmilStore" ]; then
    echo "========================================"
    echo " WARNING: Plugin folder not found!"
    echo " Installation may have failed."
    echo "========================================"
    exit 1
fi

echo "========================================"
echo "EmilPanelPro INSTALLED SUCCESSFULLY!"
echo "========================================"
echo "Plugin:  EmilPanelPro"
echo "System:  $OSTYPE ($INSTALLER)"
echo "Python:  $PYTHON_CMD ($PYTHON_VERSION)"
echo "Path:    /usr/lib/enigma2/python/Plugins/Extensions/EmilStore"
[ -d "/usr/lib64/enigma2/python/Plugins/Extensions/EmilStore" ] && \
    echo "         /usr/lib64/enigma2/python/Plugins/Extensions/EmilStore (64-bit copy)"
echo "----------------------------------------"

echo "Restarting Enigma2 in 3 seconds..."
sleep 3

if [ "$OSTYPE" = "DreamOS" ]; then
    if command -v systemctl >/dev/null 2>&1; then
        systemctl restart enigma2
    elif command -v init >/dev/null 2>&1; then
        echo "Restarting using init..."
        init 4 && sleep 2 && init 3
    else
        echo "Falling back to killall enigma2..."
        killall -9 enigma2 2>/dev/null || true
    fi
else
    echo "Restarting Enigma2..."
    killall -9 enigma2 2>/dev/null || true
fi

exit 0