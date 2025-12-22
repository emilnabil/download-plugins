#!/bin/bash

############################################
# EmilPanelPro Installer
############################################

TMPPATH="/tmp/EmilPanelPro"
PLUGIN_URL="https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilPanelPro"
PLUGIN_ARCHIVE="EmilPanelPro.tar.gz"

STATUS=""
OSTYPE=""
INSTALLER=""
PYTHON_CMD=""
PYTHON=""

############################################
# Plugin path
############################################
if [ -d "/usr/lib64" ]; then
    PLUGINPATH="/usr/lib64/enigma2/python/Plugins/Extensions/EmilStore"
else
    PLUGINPATH="/usr/lib/enigma2/python/Plugins/Extensions/EmilStore"
fi

############################################
# Detect package system
############################################
if [ -f /var/lib/dpkg/status ]; then
    STATUS="/var/lib/dpkg/status"
    OSTYPE="DreamOS"
    INSTALLER="apt-get"
elif [ -f /var/lib/opkg/status ]; then
    STATUS="/var/lib/opkg/status"
    OSTYPE="Dream"
    INSTALLER="opkg"
else
    echo "✘ Unsupported package system"
    exit 1
fi

############################################
# Remove old versions
############################################
rm -rf \
/usr/lib/enigma2/python/Plugins/Extensions/EmilPanelPro \
/usr/lib/enigma2/python/Plugins/Extensions/EmilStore \
>/dev/null 2>&1

############################################
# Detect Python
############################################
if command -v python3 >/dev/null 2>&1; then
    PYTHON_CMD="python3"
    PYTHON=$(python3 - <<EOF
import sys
print("py%s.%s" % (sys.version_info[0], sys.version_info[1]))
EOF
)
elif command -v python2 >/dev/null 2>&1; then
    PYTHON_CMD="python2"
    PYTHON="py2"
elif command -v python >/dev/null 2>&1; then
    PYTHON_CMD="python"
    PYTHON="py2"
else
    echo "✘ Python not found"
    exit 1
fi

echo "✔ Detected $PYTHON"

############################################
# Update feeds
############################################
if [ "$INSTALLER" = "apt-get" ]; then
    apt-get update >/dev/null 2>&1
else
    opkg update >/dev/null 2>&1
fi

############################################
# Install dependencies
############################################
if [ "$PYTHON" = "py2" ]; then
    echo "Installing Python2 dependencies..."
    $INSTALLER install -y \
        python \
        python-core \
        python-modules \
        python-requests \
        python-zlib \
        zlib >/dev/null 2>&1
else
    echo "Installing Python3 dependencies..."
    $INSTALLER install -y \
        python3 \
        python3-core \
        python3-modules \
        python3-requests \
        python3-zlib \
        zlib >/dev/null 2>&1
fi

############################################
# Prepare temp directory
############################################
rm -rf "$TMPPATH"
mkdir -p "$TMPPATH" || exit 1
cd "$TMPPATH" || exit 1

############################################
# Download plugin archive
############################################
echo "Downloading EmilPanelPro package..."

if [ "$OSTYPE" = "DreamOS" ]; then
    URL="https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilStore/Dreambox/EmilPanelPro.tar.gz"
else
    URL="https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilPanelPro/EmilPanelPro.tar.gz"
fi

if ! wget -q "$URL" -O "$PLUGIN_ARCHIVE"; then
    echo "✘ Failed to download archive"
    exit 1
fi

tar -xzf "$PLUGIN_ARCHIVE" -C / || exit 1

############################################
# Download compiled plugin
############################################
echo "Downloading compiled plugin for $PYTHON..."
mkdir -p "$PLUGINPATH"

if [ "$PYTHON" = "py2" ]; then
    wget -q "$PLUGIN_URL/py2/plugin.pyo" -O "$PLUGINPATH/plugin.pyo"
else
    wget -q "$PLUGIN_URL/$PYTHON/plugin.pyc" -O "$PLUGINPATH/plugin.pyc"
fi

############################################
# Verify
############################################
if [ -f "$PLUGINPATH/plugin.pyc" ] || [ -f "$PLUGINPATH/plugin.pyo" ]; then
    echo "✔ Plugin installed successfully"
else
    echo "⚠ Plugin installed but compiled file not found"
fi

############################################
# Cleanup
############################################
rm -rf "$TMPPATH"
sync

############################################
# Restart Enigma2
############################################
echo "Restarting Enigma2..."

if [ "$OSTYPE" = "DreamOS" ]; then
    systemctl restart enigma2
else
    killall -9 enigma2
fi

exit 0



