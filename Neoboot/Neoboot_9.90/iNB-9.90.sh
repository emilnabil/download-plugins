#!/bin/bash
##Command install=wget https://github.com/emilnabil/download-plugins/raw/refs/heads/main/Neoboot/Neoboot_9.90/iNB-9.90.sh -O - | /bin/sh
#####################
NEOBOOT="9.90"
VERSION="$NEOBOOT"

TMPDIR="/var/volatile/tmp"
PLUGINPATH="/usr/lib/enigma2/python/Plugins/Extensions/NeoBoot"

# Remove old version
[ -d "$PLUGINPATH" ] && rm -rf "$PLUGINPATH" >/dev/null 2>&1

# Detect OS
if [ -f /etc/opkg/opkg.conf ]; then
    STATUS="/var/lib/opkg/status"
    OPKG_UPDATE="opkg update -q"
    OPKG_INSTALL="opkg install --force-overwrite --force-reinstall -q"
    RESTART_CMD="init 6"
elif [ -f /etc/apt/apt.conf ]; then
    STATUS="/var/lib/dpkg/status"
    OPKG_UPDATE="apt-get update -qq"
    OPKG_INSTALL="apt-get install -y -qq"
    RESTART_CMD="systemctl restart enigma2"
else
    exit 1
fi

install() {
    if ! grep -qs "Package: $1" "$STATUS"; then
        $OPKG_UPDATE >/dev/null 2>&1
        $OPKG_INSTALL "$1" >/dev/null 2>&1
    fi
}

for pkg in kernel-module-nandsim mtd-utils-jffs2 lzo python-setuptools util-linux-sfdisk packagegroup-base-nfs ofgwrite bzip2 mtd-utils mtd-utils-ubifs; do
    install "$pkg"
done

mkdir -p "$TMPDIR" >/dev/null 2>&1

FILE="neoboot_${VERSION}.tar.gz"
URL="https://github.com/emilnabil/download-plugins/raw/main/Neoboot/Neoboot_${VERSION}/${FILE}"

cd "$TMPDIR" || exit 1

wget -q --no-check-certificate -O "$FILE" "$URL" >/dev/null 2>&1 || exit 1
tar -xzf "$FILE" -C / >/dev/null 2>&1 || { rm -f "$FILE"; exit 1; }

rm -f "$FILE" >/dev/null 2>&1

if [ -d "$PLUGINPATH" ]; then
    chmod 755 "$PLUGINPATH"/bin/* 2>/dev/null
    chmod 755 "$PLUGINPATH"/ex_init.py 2>/dev/null
    chmod 755 "$PLUGINPATH"/files/*.sh 2>/dev/null
    [ -d "$PLUGINPATH/ubi_reader_arm" ] && chmod -R +x "$PLUGINPATH/ubi_reader_arm" >/dev/null 2>&1
    [ -d "$PLUGINPATH/ubi_reader_mips" ] && chmod -R +x "$PLUGINPATH/ubi_reader_mips" >/dev/null 2>&1
else
    exit 1
fi

echo "Restart"

$RESTART_CMD >/dev/null 2>&1

exit 0



