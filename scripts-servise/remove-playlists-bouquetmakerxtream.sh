#!/bin/sh

echo "> Removing BouquetMakerXtream playlists, please wait..."

PLAYLIST_FILE="/etc/enigma2/bouquetmakerxtream/playlists.txt"

if [ -f "$PLAYLIST_FILE" ]; then
    sed -i '/http/d' "$PLAYLIST_FILE" >/dev/null 2>&1
    sed -i '/^$/d' "$PLAYLIST_FILE" >/dev/null 2>&1
    echo "> URLs and empty lines removed successfully."
else
    echo "> File not found: $PLAYLIST_FILE"
fi

sleep 2
exit
