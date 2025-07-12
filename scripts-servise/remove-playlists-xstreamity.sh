#!/bin/sh

echo "> removing xstreamity playlists please wait..."
sleep 3
sed -i '/http/d' /etc/enigma2/xstreamity/playlists.txt >/dev/null 2>&1
rm -rf /etc/enigma2/xstreamity/epg >/dev/null 2>&1
echo "> done"
sleep 3