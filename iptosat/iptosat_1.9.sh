#!/bin/sh

##setup command=wget https://github.com/emilnabil/download-plugins/raw/refs/heads/main/iptosat/iptosat_1.9.sh -O - | /bin/sh

echo "=============================================================="
echo "     iptosat_1.9 Installer - Python 2/3 Compatible"
echo "=============================================================="
echo ""

PYTHON_VERSION=$(python -c 'import sys; print(sys.version_info[0])' 2>/dev/null)
if [ "$PYTHON_VERSION" = "3" ]; then
    echo "✅ Detected: Python 3"
    PYTHON_CMD="python3"
elif [ "$PYTHON_VERSION" = "2" ]; then
    echo "✅ Detected: Python 2"
    PYTHON_CMD="python"
else
    echo "⚠️  Python version not detected, trying Python 2..."
    PYTHON_CMD="python"
fi

echo ""

if [ -d "/usr/share/dreambox-bootlogo" ]; then
    echo "✅ Detected: Dreambox device"
    DEVICE_TYPE="dreambox"
else
    echo "✅ Detected: Standard Enigma2 device"
    DEVICE_TYPE="standard"
fi

echo ""

echo "Removing previous version ..."
sleep 1

if [ -d /usr/lib/enigma2/python/Plugins/Extensions/IPtoSAT ]; then
    rm -rf /usr/lib/enigma2/python/Plugins/Extensions/IPtoSAT > /dev/null 2>&1

    opkg remove enigma2-plugin-extensions-iptosat

    echo '✅ Package removed.'
else
    echo "ℹ️  No previous version found"
fi

echo ""

echo "Installing required dependencies..."

if command -v opkg >/dev/null 2>&1; then
    PKG_MANAGER="opkg"
    echo "📦 Using opkg package manager"
elif command -v apt-get >/dev/null 2>&1; then
    PKG_MANAGER="apt-get"
    echo "📦 Using apt-get package manager"
else
    echo "⚠️  No package manager found! Continuing anyway..."
    PKG_MANAGER="none"
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "📦 Installing ffmpeg..."
    if [ "$PKG_MANAGER" = "opkg" ]; then
        opkg update
        opkg install ffmpeg
    elif [ "$PKG_MANAGER" = "apt-get" ]; then
        apt-get update
        apt-get install -y ffmpeg
    else
        echo "⚠️  ffmpeg not found and no package manager available!"
        echo "⚠️  Please install ffmpeg manually."
    fi
else
    echo "✅ ffmpeg already installed"
fi

echo "📦 Installing Python dependencies..."

if [ "$PYTHON_VERSION" = "3" ]; then
   
    if [ "$PKG_MANAGER" = "opkg" ]; then
        opkg install python3-pillow python3-requests
       
    elif [ "$PKG_MANAGER" = "apt-get" ]; then
        apt-get install -y python3-pil python3-requests
    fi
else
    
    if [ "$PKG_MANAGER" = "opkg" ]; then
        opkg install python-pillow python-requests
    elif [ "$PKG_MANAGER" = "apt-get" ]; then
        apt-get install -y python-pil python-requests
    fi
fi

echo ""

echo "Downloading iptosat plugin..."

cd /tmp || exit

curl -k -L --max-time 30 "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/iptosat/iptosat_1.9.tar.gz" -o /tmp/iptosat_1.9.tar.gz

if [ ! -f /tmp/iptosat_1.9.tar.gz ]; then
    echo "❌ Download failed! Please check your internet connection."
    exit 1
fi

echo "✅ Download completed"

echo ""

echo "Installing plugin..."
tar -xzf /tmp/iptosat_1.9.tar.gz -C /

if [ $? -ne 0 ]; then
    echo "❌ Extraction failed!"
    rm -f /tmp/iptosat_1.9.tar.gz
    exit 1
fi

echo "✅ Installation completed"

rm -f /tmp/iptosat_1.9.tar.gz

sleep 2
exit 0








