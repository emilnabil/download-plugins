#!/bin/sh
## Command=wget ## Command=wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/cccaminfo/cccaminfo_py2.sh -O - | /bin/sh
##
echo "Installing plugin..."
cd /tmp || exit
curl -k -L "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/cccaminfo/cccaminfo_py2.ipk" -o cccaminfo_py2.ipk

if [ -f "cccaminfo_py2.ipk" ]; then
    echo "Installation in progress..."
    opkg install cccaminfo_py2.ipk
    rm -f cccaminfo_py2.ipk
    echo "Installation completed successfully."
else
    echo "Error: Failed to download plugin."
    exit 1
fi

exit 0

