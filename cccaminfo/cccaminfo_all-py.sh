#!/bin/sh
## Command=wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/cccaminfo/cccaminfo_all-py.sh -O - | /bin/sh
##

MY_IPK_PY2="cccaminfo_py2.ipk"
MY_IPK_PY3="enigma2-plugin-extensions-cccaminfo_1.6-py3_all.ipk"
MY_URL="https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/cccaminfo"
MY_EM='============================================================================================================'
PLUGIN_DIR="/usr/lib/enigma2/python/Plugins/Extensions/CCcamInfo"

echo "$MY_EM"
echo " DOWNLOAD AND INSTALL PLUGIN "
cd /tmp || exit 1

# --- detect python ---
if command -v python3 >/dev/null 2>&1; then
    PY_VER=3
elif command -v python >/dev/null 2>&1 && \
     python -c 'import sys; sys.exit(0 if sys.version_info[0]==3 else 1)' 2>/dev/null; then
    PY_VER=3
else
    PY_VER=2
fi
echo "   Detected Python version: $PY_VER"

[ "$PY_VER" -eq 3 ] && IPK="$MY_IPK_PY3" || IPK="$MY_IPK_PY2"

# --- download first (keep old plugin if download fails) ---
echo "   Downloading $IPK ..."
if ! wget -q "$MY_URL/$IPK" -O "/tmp/$IPK"; then
    echo ">>>>  DOWNLOAD FAILED — old plugin kept intact <<<<"
    rm -f "/tmp/$IPK"
    exit 1
fi

# --- sanity check ---
if [ "$(head -c 2 "/tmp/$IPK" | od -An -tx1 | tr -d ' \n')" != "1f8b" ]; then
    echo ">>>>  INVALID IPK FILE — aborting <<<<"
    rm -f "/tmp/$IPK"
    exit 1
fi

# --- remove old + install ---
echo "   Download OK, removing old plugin ..."
rm -rf "$PLUGIN_DIR"

echo "   Installing, please wait ..."
if opkg install --force-reinstall "/tmp/$IPK"; then
    echo ">>>>  SUCCESSFULLY INSTALLED <<<<"
    RESULT=0
else
    echo ">>>>  INSTALL FAILED <<<<"
    RESULT=1
fi

rm -f "/tmp/$MY_IPK_PY2" "/tmp/$MY_IPK_PY3"

echo "********************************************************************************"
echo "   UPLOADED BY  >>>>   EMIL_NABIL "
sleep 4
echo "$MY_EM"

if [ "$RESULT" -eq 0 ]; then
    echo " Your Device Will RESTART Now "
    echo "**********************************************************************************"
    init 4 && sleep 2 && init 3
else
    echo " Installation did not complete successfully. No restart. "
fi

exit $RESULT

