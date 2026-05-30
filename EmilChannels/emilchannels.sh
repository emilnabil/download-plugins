#!/bin/sh
##command=wget -q "--no-check-certificate" https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilChannels/emilchannels.sh -O - | /bin/sh

echo "========================================="
echo "EmilChannels Plugin Installer v1.0"
echo "========================================="
echo ""

echo "Detecting system type..."

if command -v apt-get > /dev/null 2>&1; then
    INSTALLER="apt-get"
    SYSTEM="DreamOS"
    DREAMBOX=1
    echo "Detected: DreamOS (DreamBox with apt-get)"
elif command -v opkg > /dev/null 2>&1; then
    INSTALLER="opkg"
    SYSTEM="OpenSource"
    DREAMBOX=0
    echo "Detected: OpenSource Enigma2 (opkg)"
else
    echo "No supported package manager found!"
    exit 1
fi

if command -v python3 > /dev/null 2>&1; then
    PYTHON_CMD="python3"
    PYTHON_VER="3"
    echo "Python 3 detected"
elif command -v python > /dev/null 2>&1; then
    PYTHON_CMD="python"
    PYTHON_VER="2"
    echo "Python 2 detected"
else
    echo "Python is not installed!"
    exit 1
fi

echo ""

if [ $DREAMBOX -eq 1 ]; then
    DOWNLOAD_URL="https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilChannels/dreambox/EmilChannels.tar.gz"
    echo "Using Dreambox specific package..."
else
    DOWNLOAD_URL="https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilChannels/opensurce/EmilChannels.tar.gz"
    echo "Using OpenSource image package..."
fi

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
    curl -k -L --max-time 120 "$DOWNLOAD_URL" -o /tmp/EmilChannels.tar.gz
elif command -v wget > /dev/null 2>&1; then
    wget --no-check-certificate --timeout=120 -O /tmp/EmilChannels.tar.gz "$DOWNLOAD_URL"
else
    echo "ERROR: Neither curl nor wget found. Please install one of them."
    exit 1
fi

if [ ! -f /tmp/EmilChannels.tar.gz ] || [ ! -s /tmp/EmilChannels.tar.gz ]; then
    echo "ERROR: Download failed or file is empty!"
    echo "Tried URL: $DOWNLOAD_URL"
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
    
    if [ "$INSTALLER" = "opkg" ]; then
        echo "opkg package manager found."
        opkg update > /dev/null 2>&1
        
        if [ "$PYTHON_VER" = "3" ]; then
            if python3 -c "import urllib.request" 2>/dev/null; then
                echo "[OK] urllib module found"
            else
                echo "[INFO] Installing urllib..."
                opkg install python3-urllib3 > /dev/null 2>&1
            fi
            
            if python3 -c "import ssl" 2>/dev/null; then
                echo "[OK] ssl module found"
            else
                echo "[INFO] Installing ssl..."
                opkg install python3-ssl > /dev/null 2>&1
            fi
            
            if python3 -c "import tarfile" 2>/dev/null; then
                echo "[OK] tarfile module found"
            else
                echo "[INFO] Installing tarfile..."
                opkg install python3-tarfile > /dev/null 2>&1
            fi
        else
            if python -c "import urllib2" 2>/dev/null; then
                echo "[OK] urllib module found"
            else
                echo "[INFO] Installing urllib..."
                opkg install python-urllib3 > /dev/null 2>&1
            fi
            
            if python -c "import ssl" 2>/dev/null; then
                echo "[OK] ssl module found"
            else
                echo "[INFO] Installing ssl..."
                opkg install python-ssl > /dev/null 2>&1
            fi
            
            if python -c "import tarfile" 2>/dev/null; then
                echo "[OK] tarfile module found"
            else
                echo "[INFO] Installing tarfile..."
                opkg install python-tarfile > /dev/null 2>&1
            fi
        fi
        
    elif [ "$INSTALLER" = "apt-get" ]; then
        echo "apt package manager found."
        apt-get update > /dev/null 2>&1
        
        if [ "$PYTHON_VER" = "3" ]; then
            if python3 -c "import urllib.request" 2>/dev/null; then
                echo "[OK] urllib module found"
            else
                echo "[INFO] Installing urllib..."
                apt-get install python3-urllib3 -y > /dev/null 2>&1
            fi
            
            if python3 -c "import ssl" 2>/dev/null; then
                echo "[OK] ssl module found"
            else
                echo "[INFO] Installing ssl..."
                apt-get install python3-openssl -y > /dev/null 2>&1
            fi
        else
            if python -c "import urllib2" 2>/dev/null; then
                echo "[OK] urllib module found"
            else
                echo "[INFO] Installing urllib..."
                apt-get install python-urllib3 -y > /dev/null 2>&1
            fi
            
            if python -c "import ssl" 2>/dev/null; then
                echo "[OK] ssl module found"
            else
                echo "[INFO] Installing ssl..."
                apt-get install python-openssl -y > /dev/null 2>&1
            fi
        fi
    fi
    
    echo ""
    echo "========================================="
    echo "Installation completed!"
    echo "System Type: $SYSTEM"
    echo "Python Version: $PYTHON_VER"
    echo "Package Manager: $INSTALLER"
    echo "Please restart Enigma2 to use the plugin."
    echo "Menu -> Plugins -> EmilChannels"
    echo "========================================="
else
    echo "ERROR: Extraction failed!"
    exit 1
fi

rm -f /tmp/EmilChannels.tar.gz

exit 0

