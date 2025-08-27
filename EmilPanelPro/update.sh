#!/bin/bash

## setup command:
##   wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/EmilPanelPro/emilpanelpro.sh -O - | /bin/sh

TMPPATH="/tmp/EmilPanelPro"
PLUGIN_URL="https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilPanelPro/dream"
STATUS=""
OSTYPE=""
INSTALLER=""
PYTHON_CMD=""
PYTHON=""
PACKAGE_SIX=""
PACKAGE_REQUESTS=""
PLUGIN_ARCHIVE="EmilPanelPro.tar.gz"

if [ -d "/usr/lib64" ]; then
    PLUGINPATH="/usr/lib64/enigma2/python/Plugins/Extensions/EmilPanelPro"
else
    PLUGINPATH="/usr/lib/enigma2/python/Plugins/Extensions/EmilPanelPro"
fi

if [ -f /var/lib/dpkg/status ]; then
    STATUS="/var/lib/dpkg/status"
    OSTYPE="DreamOS"
    INSTALLER="apt-get"
elif [ -f /var/lib/opkg/status ]; then
    STATUS="/var/lib/opkg/status"
    OSTYPE="Dream"
    INSTALLER="opkg"
else
    echo "✘ Unsupported package system."
    exit 1
fi

if command -v python3 >/dev/null 2>&1; then
    PYTHON_CMD="python3"
elif command -v python >/dev/null 2>&1; then
    PYTHON_CMD="python"
elif command -v python2 >/dev/null 2>&1; then
    PYTHON_CMD="python2"
else
    echo "✘ Python is not installed."
    exit 1
fi

if $PYTHON_CMD -c 'import sys; sys.exit(0) if sys.version_info[0] == 3 else sys.exit(1)'; then
    echo "✔ Python 3 detected"
    PYTHON="py3"
    PACKAGE_SIX="python3-six"
    PACKAGE_REQUESTS="python3-requests"
else
    echo "✔ Python 2 detected"
    PYTHON="py2"
    PACKAGE_SIX=""
    PACKAGE_REQUESTS="python-requests"
fi

echo "Installing dependencies..."
$INSTALLER update -q >/dev/null 2>&1

if [ -n "$PACKAGE_SIX" ] && ! grep -qs "Package: $PACKAGE_SIX" "$STATUS"; then
    $INSTALLER install -y "$PACKAGE_SIX" >/dev/null 2>&1
fi

if ! grep -qs "Package: $PACKAGE_REQUESTS" "$STATUS"; then
    $INSTALLER install -y "$PACKAGE_REQUESTS" >/dev/null 2>&1
fi

rm -rf "$TMPPATH" "$PLUGINPATH"
mkdir -p "$TMPPATH"

cd "$TMPPATH" || exit 1

echo "Downloading EmilPanelPro ($PYTHON)..."
if command -v dpkg >/dev/null 2>&1; then
    URL="$PLUGIN_URL/EmilPanelPro.tar.gz"
else
    URL="https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilPanelPro/${PYTHON}/${PLUGIN_ARCHIVE}"
fi

wget -q "$URL" -O "$TMPPATH/$PLUGIN_ARCHIVE"
tar -xzf "$TMPPATH/$PLUGIN_ARCHIVE" -C /

sync
echo "#########################################################"
echo "#  ✔ EmilPanelPro INSTALLED SUCCESSFULLY               #"
echo "#         Uploaded by Emil Nabil                       #"
echo "#########################################################"

rm -rf "$TMPPATH"
sync

if [ "$OSTYPE" = "DreamOS" ]; then
    systemctl restart enigma2
else
    killall -9 enigma2
fi

exit 0


