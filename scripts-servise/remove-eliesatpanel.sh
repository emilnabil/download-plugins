#!/bin/sh

echo "> cleaning up, please wait..."
sleep 2

# Check package manager and remove plugin
if command -v dpkg >/dev/null 2>&1; then
    apt-get remove -y enigma2-plugin-extensions-eliesatpanel >/dev/null 2>&1
else
    opkg remove enigma2-plugin-extensions-eliesatpanel >/dev/null 2>&1
fi

# Remove plugin directory if exists
rm -rf /usr/lib/enigma2/python/Plugins/Extensions/ElieSatPanel >/dev/null 2>&1

# Clean package manager cache
rm -rf /var/cache/opkg/* >/dev/null 2>&1
rm -rf /var/lib/opkg/lists/* >/dev/null 2>&1
rm -rf /run/opkg.lock >/dev/null 2>&1
rm -rf /var/volatile/cache/opkg >/dev/null 2>&1

# Remove plugin-related info files
find /var/lib/opkg/info -type f -name "*eliesatpanel*" -exec rm -f {} \; >/dev/null 2>&1

echo "> done"
sleep 2
exit

