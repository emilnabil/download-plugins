#!/bin/bash
#
##setup command=wget https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EStalker/EStalker.sh -O - | /bin/sh

PLUGIN_URL="https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EStalker"

if [ -d /usr/lib64 ]; then
    PLUGINPATH="/usr/lib64/enigma2/python/Plugins/Extensions/EStalker"
else
    PLUGINPATH="/usr/lib/enigma2/python/Plugins/Extensions/EStalker"
fi

if [ -f /var/lib/dpkg/status ]; then
    STATUS="/var/lib/dpkg/status"
    OSTYPE="DreamOs"
else
    STATUS="/var/lib/opkg/status"
    OSTYPE="Dream"
fi

echo "Checking Python version..."
pyv="$(python -V 2>&1)"
echo "$pyv"
echo ""
echo "Checking dependencies..."

if [ -d /etc/opkg ]; then
    opkg update > /dev/null 2>&1

    if [[ $pyv =~ "Python 3" ]]; then
        echo "Checking python3-requests..."
        python -c "import requests" 2>/dev/null || opkg install python3-requests > /dev/null 2>&1

        echo "Checking python3-multiprocessing..."
        python -c "from multiprocessing.pool import ThreadPool" 2>/dev/null || opkg install python3-multiprocessing > /dev/null 2>&1

        echo "Checking python3-six..."
        python -c "import six" 2>/dev/null || opkg install python3-six > /dev/null 2>&1
    else
        echo "Checking python-requests..."
        python -c "import requests" 2>/dev/null || opkg install python-requests > /dev/null 2>&1

        echo "Checking python-multiprocessing..."
        python -c "from multiprocessing.pool import ThreadPool" 2>/dev/null || opkg install python-multiprocessing > /dev/null 2>&1

        echo "Checking python-image..."
        python -c "import PIL" 2>/dev/null || { opkg install python-image > /dev/null 2>&1; opkg install python-imaging > /dev/null 2>&1; }

        echo "Checking python-six..."
        python -c "import six" 2>/dev/null || opkg install python-six > /dev/null 2>&1
    fi
else
    apt-get update > /dev/null 2>&1

    if [[ $pyv =~ "Python 3" ]]; then
        echo "Checking python3-requests..."
        python -c "import requests" 2>/dev/null || apt-get -y install python3-requests > /dev/null 2>&1

        echo "Checking python3-multiprocessing..."
        python -c "from multiprocessing.pool import ThreadPool" 2>/dev/null || apt-get -y install python3-multiprocessing > /dev/null 2>&1

        echo "Checking python3-six..."
        python -c "import six" 2>/dev/null || apt-get -y install python3-six > /dev/null 2>&1
    else
        echo "Checking python-requests..."
        python -c "import requests" 2>/dev/null || apt-get -y install python-requests > /dev/null 2>&1

        echo "Checking python-multiprocessing..."
        python -c "from multiprocessing.pool import ThreadPool" 2>/dev/null || apt-get -y install python-multiprocessing > /dev/null 2>&1

        echo "Checking python-image..."
        python -c "import PIL" 2>/dev/null || { apt-get -y install python-image > /dev/null 2>&1; apt-get -y install python-imaging > /dev/null 2>&1; }

        echo "Checking python-six..."
        python -c "import six" 2>/dev/null || apt-get -y install python-six > /dev/null 2>&1
    fi
fi

echo ""
echo "Installing required system packages..."
opkg update > /dev/null 2>&1
opkg install python python-core python-json python-netclient python-codecs python-xml python-shell python-subprocess python-multiprocessing > /dev/null 2>&1
opkg install wget curl busybox tar gzip > /dev/null 2>&1
opkg install enigma2-plugin-systemplugins-skinselector enigma2-plugin-extensions-openwebif > /dev/null 2>&1
opkg install opkg > /dev/null 2>&1

echo ""
echo "Cleaning previous plugin installation..."
rm -rf "$PLUGINPATH"
cd /tmp || exit 1

echo "Downloading plugin..."
wget "$PLUGIN_URL/Estalker.tar.gz" -O Estalker.tar.gz > /dev/null 2>&1

if [ -f Estalker.tar.gz ]; then
    echo "Extracting plugin..."
    tar -xzf Estalker.tar.gz -C / > /dev/null 2>&1
    sync

    echo "#########################################################"
    echo "#        EStalker INSTALLED SUCCESSFULLY                #"
    echo "#########################################################"

    if [ -d /usr/lib64 ]; then
        RESTART_CMD="systemctl restart enigma2"
    else
        RESTART_CMD="killall -9 enigma2"
    fi

    echo "Cleaning temporary files..."
    rm -f /tmp/Estalker.tar.gz > /dev/null 2>&1
    sync

    echo "#########################################################"
    echo "#           Your device will RESTART now                #"
    echo "#########################################################"
    sleep 5
    $RESTART_CMD
    exit 0
else
    echo "#########################################################"
    echo "#  ERROR: Failed to download Estalker.tar.gz            #"
    echo "#########################################################"
    exit 1
fi

