#!/bin/sh

# Detect Python version
PYTHON_VERSION=$(python -c "import platform; print(platform.python_version())" 2>/dev/null)
if echo "$PYTHON_VERSION" | grep -q '^3\.'; then
   PYTHON="PY3"
elif echo "$PYTHON_VERSION" | grep -q '^2\.'; then
   PYTHON="PY2"
else
   echo "> Python not found!"
   exit 1
fi

# Detect package manager
if command -v apt-get >/dev/null 2>&1; then
    INSTALL="apt-get install -y"
    CHECK_INSTALLED="dpkg -l"
    OS='DreamOS'
    apt-get update >/dev/null 2>&1
elif command -v opkg >/dev/null 2>&1; then
    INSTALL="opkg install --force-reinstall --force-depends"
    CHECK_INSTALLED="opkg list-installed"
    OS='Opensource'
else
    echo "> No package manager found!"
    exit 1
fi

# Common packages (both PY2 and PY3)
COMMON_PACKAGES="wget tar zip ar curl alsa-plugins alsa-conf alsa-state libasound2 libc6 libgcc1 libstdc++6 \
gstreamer1.0-plugins-good gstreamer1.0-plugins-base gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly \
ffmpeg exteplayer3 gstplayer enigma2 enigma2-plugin-systemplugins-serviceapp"

# Python 3 specific packages
PY3_PACKAGES="python3-lxml python3-requests python3-beautifulsoup4 python3-rarfile python3-cfscrape \
livestreamersrv python3-six python3-sqlite3 python3-pycrypto f4mdump python3-image python3-imaging \
python3-argparse python3-multiprocessing python3-mmap python3-ndg-httpsclient python3-pydoc python3-xmlrpc \
python3-certifi python3-urllib3 python3-chardet python3-pysocks python3-js2py python3-pillow"

# Python 2 specific packages
PY2_PACKAGES="python-lxml python-requests python-beautifulsoup4 python-rarfile python-cfscrape \
livestreamer python-six python-sqlite3 python-pycrypto f4mdump python-image python-imaging \
python-argparse python-multiprocessing python-mmap python-ndg-httpsclient python-pydoc python-xmlrpc \
python-certifi python-urllib3 python-chardet python-pysocks"

# Special libs based on Python version number
case "$PYTHON_VERSION" in
2.7.18)
    EXTRA_LIBS="libavcodec58 libavformat58 libpython2.7-1.0"
    ;;
3.9.9)
    EXTRA_LIBS="libavcodec58 libavformat58 libpython3.9-1.0"
    ;;
3.10.*)
    EXTRA_LIBS="libavcodec60 libavformat60 libpython3.10-1.0"
    ;;
3.11.*)
    EXTRA_LIBS="libavcodec60 libavformat60 libpython3.11-1.0"
    ;;
3.12.*)
    EXTRA_LIBS="libavcodec60 libavformat60 libpython3.12-1.0"
    ;;
*)
    EXTRA_LIBS="libavcodec58 libavformat58"
    ;;
esac

# Final package list to install
ALL_PACKAGES="$COMMON_PACKAGES $EXTRA_LIBS"
[ "$PYTHON" = "PY3" ] && ALL_PACKAGES="$ALL_PACKAGES $PY3_PACKAGES"
[ "$PYTHON" = "PY2" ] && ALL_PACKAGES="$ALL_PACKAGES $PY2_PACKAGES"

# Silent installation loop
for pkg in $ALL_PACKAGES; do
    if ! $CHECK_INSTALLED | grep -qw "$pkg"; then
        echo "> Installing: $pkg"
        $INSTALL "$pkg" >/dev/null 2>&1
    fi
done

echo "> Done. All packages installed."
exit 0

