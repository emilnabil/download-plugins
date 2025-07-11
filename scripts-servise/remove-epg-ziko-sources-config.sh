#!/bin/sh
#
echo "> Removing source files, please wait..."
sleep 3

rm -f /etc/epgimport/custom.sources.xml >/dev/null 2>&1

rm -f /etc/epgimport/ziko_config/* >/dev/null 2>&1

rm -f /etc/epgimport/ziko_epg/* >/dev/null 2>&1

echo "> Done. Files removed successfully."
sleep 2
exit

