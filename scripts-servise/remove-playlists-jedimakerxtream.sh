#!/bin/sh

echo "> removing jedimakerxtream playlists please wait..."
sleep 3
sed -i '/http/d' /etc/enigma2/jediplaylists/playlists.txt >/dev/null 2>&1
echo "> done"
sleep 3