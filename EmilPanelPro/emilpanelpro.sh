#!/bin/bash

## setup command:
##   wget https://github.com/emilnabil/dreambox/raw/refs/heads/main/emilpanelpro.sh -O - | /bin/sh

TMPPATH="/tmp/EmilPanelPro"
PLUGIN_URL="https://github.com/emilnabil/dreambox/raw/refs/heads/main"
STATUS=""
OSTYPE=""
INSTALLER=""
PYTHON_CMD=""
PYTHON=""
PACKAGE_SIX=""
PACKAGE_REQUESTS=""
PLUGIN_ARCHIVE="EmilPanelPro.tar.gz"

# determine plugin path
if [ -d "/usr/lib64" ]; then
    PLUGINPATH="/usr/lib64/enigma2/python/Plugins/Extensions/EmilPanelPro"
else
    PLUGINPATH="/usr/lib/enigma2/python/Plugins/Extensions/EmilPanelPro"
fi

# detect package system
if [ -f /var/lib/dpkg/status ]; then
    STATUS="/var/lib/dpkg/status"
    OSTYPE="DreamOs"
    INSTALLER="apt-get"
elif [ -f /var/lib/opkg/status ]; then
    STATUS="/var/lib/opkg/status"
    OSTYPE="Dream"
    INSTALLER="opkg"
else
    echo "✘ Unsupported package system."
    exit 1
fi

# detect python command
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

# detect python version
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

# update and install dependencies
echo "Installing dependencies..."
$INSTALLER update -q >/dev/null 2>&1

if [ -n "$PACKAGE_SIX" ] && ! grep -qs "Package: $PACKAGE_SIX" "$STATUS"; then
    $INSTALLER install -y "$PACKAGE_SIX" >/dev/null 2>&1
fi

if ! grep -qs "Package: $PACKAGE_REQUESTS" "$STATUS"; then
    $INSTALLER install -y "$PACKAGE_REQUESTS" >/dev/null 2>&1
fi

# prepare workspace
rm -rf "$TMPPATH" "$PLUGINPATH"
mkdir -p "$TMPPATH"

cd "$TMPPATH" || exit 1

# download and extract plugin
echo "Downloading EmilPanelPro ($PYTHON)..."
if command -v dpkg >/dev/null 2>&1; then
    URL="$PLUGIN_URL/EmilPanelPro.tar.gz"
else
    URL="https://dreambox4u.com/emilnabil237/plugins/emilpanelpro/${PYTHON}/${PLUGIN_ARCHIVE}"
fi

wget -q "$URL" -O "$TMPPATH/$PLUGIN_ARCHIVE"
tar -xzf "$TMPPATH/$PLUGIN_ARCHIVE" -C /

# finalize
sync
echo "#########################################################"
echo "#  ✔ EmilPanelPro INSTALLED SUCCESSFULLY               #"
echo "#         Uploaded by Emil Nabil                       #"
echo "#########################################################"

# cleanup
rm -rf "$TMPPATH"
sync

exit 0



