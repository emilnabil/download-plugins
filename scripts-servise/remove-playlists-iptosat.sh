#!/bin/sh

echo "> removing iptosat playlists please wait..."
sleep 3

if [ -d /usr/lib/enigma2/python/Plugins/Extensions/IPtoSAT ]; then

file1="/tmp/tmpFile"
file2="/etc/enigma2/iptosat.json"
file3="/tmp/tmpFile1"
file4="/etc/enigma2/iptosat.conf"


rm -rf "$file1" > /dev/null 2>&1
rm -rf "$file3" > /dev/null 2>&1

cat <<F >"$file1"
{
    "playlist":[{
        "channel":"TEST",
        "url":"http://URL/USER/PASS/CH_ID"

    }]
}

F
mv "$file1" "$file2"

cat <<F >"$file3"
[IPtoSat]
Host=http://host:port
User=user
Pass=pass
F
mv "$file3" "$file4"

else
echo "> install iptosat plugin and try again"

exit 1

fi
echo "> done"
sleep 3