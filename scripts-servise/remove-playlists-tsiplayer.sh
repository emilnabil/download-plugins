#!/bin/sh

echo "> removing e2iplayer playlists please wait..."
sleep 3
sed -i '/http/d' /etc/tsiplayer_xtream.conf >/dev/null 2>&1
echo "> done"
sleep 3
