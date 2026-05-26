#!/bin/sh
##command=wget -q "--no-check-certificate" https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilChannels/emilchannels.sh -O - | /bin/sh

echo "========================================="
echo "EmilChannels Plugin Installer v1.0"
echo "========================================="
echo ""

echo "Removing previous version ..."
sleep 2

if [ -d /usr/lib/enigma2/python/Plugins/Extensions/EmilChannels ]; then
    rm -rf /usr/lib/enigma2/python/Plugins/Extensions/EmilChannels > /dev/null 2>&1
    echo "Previous version removed."
else
    echo "No previous version found."
fi

echo ""

cd /tmp || exit

if command -v curl > /dev/null 2>&1; then
    curl -k -L --max-time 120 "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilChannels/EmilChannels.tar.gz" -o /tmp/EmilChannels.tar.gz
elif command -v wget > /dev/null 2>&1; then
    wget --no-check-certificate --timeout=120 -O /tmp/EmilChannels.tar.gz "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilChannels/EmilChannels.tar.gz"
else
    echo "ERROR: Neither curl nor wget found. Please install one of them."
    exit 1
fi

if [ ! -f /tmp/EmilChannels.tar.gz ] || [ ! -s /tmp/EmilChannels.tar.gz ]; then
    echo "ERROR: Download failed or file is empty!"
    exit 1
fi

echo "Installing EmilChannels plugin..."
tar -xzf /tmp/EmilChannels.tar.gz -C /

if [ $? -eq 0 ]; then
    echo ""
    echo "Plugin installed successfully!"
    echo ""
    echo "Checking Python dependencies..."
    echo ""
    
    if command -v opkg > /dev/null 2>&1; then
        echo "opkg package manager found."
        opkg update > /dev/null 2>&1
        
        if python -c "import urllib2" 2>/dev/null || python3 -c "import urllib.request" 2>/dev/null; then
            echo "[OK] urllib module found"
        else
            echo "[INFO] Installing urllib..."
            opkg install python-urllib3 python3-urllib3 > /dev/null 2>&1
        fi
        
        if python -c "import ssl" 2>/dev/null || python3 -c "import ssl" 2>/dev/null; then
            echo "[OK] ssl module found"
        else
            echo "[INFO] Installing ssl..."
            opkg install python-ssl python3-ssl > /dev/null 2>&1
        fi
        
        if python -c "import tarfile" 2>/dev/null || python3 -c "import tarfile" 2>/dev/null; then
            echo "[OK] tarfile module found"
        else
            echo "[INFO] Installing tarfile..."
            opkg install python-tarfile python3-tarfile > /dev/null 2>&1
        fi
        
    elif command -v apt-get > /dev/null 2>&1; then
        echo "apt package manager found."
        apt-get update > /dev/null 2>&1
        
        if python -c "import urllib2" 2>/dev/null || python3 -c "import urllib.request" 2>/dev/null; then
            echo "[OK] urllib module found"
        else
            echo "[INFO] Installing urllib..."
            apt-get install python-urllib3 python3-urllib3 -y > /dev/null 2>&1
        fi
        
        if python -c "import ssl" 2>/dev/null || python3 -c "import ssl" 2>/dev/null; then
            echo "[OK] ssl module found"
        else
            echo "[INFO] Installing ssl..."
            apt-get install python-openssl python3-openssl -y > /dev/null 2>&1
        fi
    else
        echo "[WARN] No package manager found. Skipping dependency check."
    fi
    
    echo ""
    echo "========================================="
    echo "Installation completed!"
    echo "Please restart Enigma2 to use the plugin."
    echo "Menu -> Plugins -> EmilChannels"
    echo "========================================="
else
    echo "ERROR: Extraction failed!"
    exit 1
fi

rm -f /tmp/EmilChannels.tar.gz

exit 0

