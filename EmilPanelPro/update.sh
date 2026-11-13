
#!/bin/sh

TMPPATH="/tmp/EmilPanelPro"
STAGE="$TMPPATH/stage"
PLUGIN_ARCHIVE="EmilPanelPro.tar.gz"
PLUGIN_NAME="EmilStore"

PLUGIN_DIR="/usr/lib/enigma2/python/Plugins/Extensions/$PLUGIN_NAME"
PLUGIN_DIR64="/usr/lib64/enigma2/python/Plugins/Extensions/$PLUGIN_NAME"

STATUS=""
OSTYPE=""
INSTALLER=""
PYTHON_CMD=""
PYTHON=""
PYTHON_VERSION=""
PYTHON_MAJOR=""

echo "========================================"
echo "   EmilPanelPro Update Installer"
echo "========================================"

if [ -f /etc/opkg/opkg.conf ] && [ -d /usr/lib/enigma2 ] && ! command -v dpkg >/dev/null 2>&1; then
    STATUS="/var/lib/opkg/status"
    OSTYPE="OpenSource"
    INSTALLER="opkg"
elif command -v dpkg >/dev/null 2>&1 && [ -d /usr/lib/enigma2 ]; then
    STATUS="/var/lib/dpkg/status"
    OSTYPE="DreamOS"
    INSTALLER="apt-get"
elif [ -f /etc/opkg/opkg.conf ]; then
    STATUS="/var/lib/opkg/status"
    OSTYPE="OpenSource"
    INSTALLER="opkg"
elif command -v apt-get >/dev/null 2>&1; then
    STATUS="/var/lib/dpkg/status"
    OSTYPE="DreamOS"
    INSTALLER="apt-get"
else
    echo "ERROR: Unsupported package system!"
    exit 1
fi

echo "Detected: $OSTYPE ($INSTALLER)"

get_python_info() {
    candidate="$1"

    command -v "$candidate" >/dev/null 2>&1 || return 1

    version=$("$candidate" -c 'import sys; print("%d.%d" % sys.version_info[:2])' 2>/dev/null)
    major=$("$candidate" -c 'import sys; print(sys.version_info[0])' 2>/dev/null)

    [ -n "$version" ] && [ -n "$major" ] || return 1

    case "$major" in
        2) PYTHON="py2" ;;
        3) PYTHON="py3" ;;
        *) return 1 ;;
    esac

    PYTHON_CMD="$candidate"
    PYTHON_VERSION="$version"
    PYTHON_MAJOR="$major"

    return 0
}

find_python_major() {
    required_major="$1"

    for candidate in python2 python python3; do
        if get_python_info "$candidate"; then
            [ "$PYTHON_MAJOR" = "$required_major" ] && return 0
        fi
    done

    return 1
}

detect_enigma_python() {
    ENIGMA_PID=$(pidof enigma2 2>/dev/null | awk '{print $1}')
    detected_major=""

    if [ -n "$ENIGMA_PID" ] && [ -r "/proc/$ENIGMA_PID/maps" ]; then
        if grep -q 'libpython2\.' "/proc/$ENIGMA_PID/maps"; then
            detected_major="2"
            echo "Detected Python 2 from Enigma2 process libraries"
        elif grep -q 'libpython3\.' "/proc/$ENIGMA_PID/maps"; then
            detected_major="3"
            echo "Detected Python 3 from Enigma2 process libraries"
        fi
    fi

    if [ -z "$detected_major" ] && command -v ldd >/dev/null 2>&1; then
        for binary in /usr/bin/enigma2 /usr/bin/enigma2.bin; do
            [ -x "$binary" ] || continue

            libraries=$(ldd "$binary" 2>/dev/null)

            if echo "$libraries" | grep -q 'libpython2\.'; then
                detected_major="2"
                echo "Detected Python 2 from Enigma2 binary"
                break
            elif echo "$libraries" | grep -q 'libpython3\.'; then
                detected_major="3"
                echo "Detected Python 3 from Enigma2 binary"
                break
            fi
        done
    fi

    if [ -n "$detected_major" ]; then
        find_python_major "$detected_major" && return 0
    fi

    echo "Checking Enigma2 Python module compatibility..."

    for candidate in python2 python python3; do
        if command -v "$candidate" >/dev/null 2>&1; then
            if PYTHONPATH="/usr/lib/enigma2/python:/usr/lib/python" \
                "$candidate" -c 'import enigma' >/dev/null 2>&1; then

                if get_python_info "$candidate"; then
                    echo "Enigma2 module verified using $PYTHON_CMD"
                    return 0
                fi
            fi
        fi
    done

    echo "ERROR: Cannot reliably detect Enigma2 Python version!"
    return 1
}

echo "Checking Enigma2 Python environment..."

if ! detect_enigma_python; then
    echo "Update aborted to protect existing installation."
    exit 1
fi

echo "----------------------------------------"
echo "Python:      $PYTHON"
echo "Interpreter: $PYTHON_CMD"
echo "Version:     $PYTHON_VERSION"
echo "----------------------------------------"

echo "Checking download tools..."

if ! command -v wget >/dev/null 2>&1; then
    echo "wget not found, trying to install..."

    if [ "$INSTALLER" = "DreamOS" ]; then
        apt-get update >/dev/null 2>&1
        apt-get install -y wget >/dev/null 2>&1
    else
        opkg update >/dev/null 2>&1
        opkg install wget >/dev/null 2>&1
    fi
fi

if ! command -v wget >/dev/null 2>&1 && ! command -v curl >/dev/null 2>&1; then
    echo "ERROR: Neither wget nor curl is available!"
    exit 1
fi

echo "Preparing temporary directory..."

rm -rf "$TMPPATH"

mkdir -p "$STAGE" || {
    echo "ERROR: Cannot create temporary directory!"
    exit 1
}

cd "$TMPPATH" || {
    echo "ERROR: Cannot enter temporary directory!"
    rm -rf "$TMPPATH"
    exit 1
}

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

echo "Downloading update..."
echo "$URL"

DOWNLOAD_OK=0

if command -v curl >/dev/null 2>&1; then
    curl -fL -sS --retry 2 "$URL" -o "$PLUGIN_ARCHIVE"
    [ $? -eq 0 ] && DOWNLOAD_OK=1
fi

if [ "$DOWNLOAD_OK" -ne 1 ] && command -v wget >/dev/null 2>&1; then
    wget --no-check-certificate -q -O "$PLUGIN_ARCHIVE" "$URL"
    [ $? -eq 0 ] && DOWNLOAD_OK=1
fi

if [ "$DOWNLOAD_OK" -ne 1 ] || [ ! -s "$PLUGIN_ARCHIVE" ]; then
    echo "ERROR: Update download failed!"
    cd /
    rm -rf "$TMPPATH"
    exit 1
fi

echo "Verifying update archive..."

if ! tar -tzf "$PLUGIN_ARCHIVE" >/dev/null 2>&1; then
    echo "ERROR: Archive is corrupted!"
    cd /
    rm -rf "$TMPPATH"
    exit 1
fi

echo "Extracting update to temporary directory..."

if ! tar -xzf "$PLUGIN_ARCHIVE" -C "$STAGE"; then
    echo "ERROR: Extraction failed!"
    cd /
    rm -rf "$TMPPATH"
    exit 1
fi

if [ ! -d "$STAGE$PLUGIN_DIR" ]; then
    echo "ERROR: Expected plugin directory not found!"
    echo "Expected: $PLUGIN_DIR"
    find "$STAGE" -maxdepth 7 -type d 2>/dev/null | head -30
    cd /
    rm -rf "$TMPPATH"
    exit 1
fi

echo "Update archive verified successfully"

echo "Checking existing installation..."

if [ ! -d "$PLUGIN_DIR" ]; then
    echo "WARNING: Existing plugin directory not found."
    echo "A new installation will be performed."
fi

echo "Installing update..."

if ! rm -rf "$PLUGIN_DIR"; then
    echo "ERROR: Cannot remove old plugin directory!"
    cd /
    rm -rf "$TMPPATH"
    exit 1
fi

if ! cp -a "$STAGE$PLUGIN_DIR" "$PLUGIN_DIR"; then
    echo "ERROR: Failed to install updated plugin!"
    cd /
    rm -rf "$TMPPATH"
    exit 1
fi

if [ ! -d "$PLUGIN_DIR" ]; then
    echo "ERROR: Plugin verification failed!"
    cd /
    rm -rf "$TMPPATH"
    exit 1
fi

if [ "$OSTYPE" = "DreamOS" ] && [ -d "/usr/lib64/enigma2/python/Plugins" ]; then
    echo "Updating 64-bit plugin path..."

    mkdir -p "/usr/lib64/enigma2/python/Plugins/Extensions"

    rm -rf "$PLUGIN_DIR64"

    if cp -a "$PLUGIN_DIR" "$PLUGIN_DIR64"; then
        echo "64-bit plugin copy updated"
    else
        echo "WARNING: 64-bit copy failed"
    fi
fi

cd /
rm -rf "$TMPPATH"

sync

echo "========================================"
echo "EmilPanelPro UPDATED SUCCESSFULLY!"
echo "========================================"
echo "Plugin:      $PLUGIN_NAME"
echo "System:      $OSTYPE"
echo "Python:      $PYTHON"
echo "Version:     $PYTHON_VERSION"
echo "Interpreter: $PYTHON_CMD"
echo "Path:        $PLUGIN_DIR"

if [ -d "$PLUGIN_DIR64" ]; then
    echo "64-bit Path: $PLUGIN_DIR64"
fi

echo "----------------------------------------"
echo "Restarting Enigma2 in 3 seconds..."
sleep 3

if [ "$OSTYPE" = "DreamOS" ] && command -v systemctl >/dev/null 2>&1; then
    systemctl restart enigma2
elif command -v init >/dev/null 2>&1; then
    echo "Restarting using init..."
    init 4
    sleep 2
    init 3
else
    echo "Restarting Enigma2..."
    killall -9 enigma2 2>/dev/null || true
fi

exit 0

