#!/bin/sh

echo "> Removing IPAudio playlists, please wait..."
sleep 2

# Check for IPAudio plugin directories
IPAUDIO_DIR1="/usr/lib/enigma2/python/Plugins/Extensions/IPAudio"
IPAUDIO_DIR2="/usr/lib/enigma2/python/Plugins/Extensions/IPaudioPro"
OUTPUT_FILE="/etc/enigma2/ipaudio.json"
TMP_FILE="/tmp/tmpFile"

# Remove temporary file if exists
rm -f "$TMP_FILE" >/dev/null 2>&1

if [ -d "$IPAUDIO_DIR1" ]; then
    # For IPAudio plugin
    cat <<EOF >"$TMP_FILE"
{
    "playlist":[{
        "channel":"TEST",
        "url":"http://URL/USER/PASS/CH_ID"
    }]
}
EOF

    mv "$TMP_FILE" "$OUTPUT_FILE"

elif [ -d "$IPAUDIO_DIR2" ]; then
    # For IPAudioPro plugin
    cat <<EOF >"$TMP_FILE"
{
    "streams": [
        {
            "name": "this field is used to display picons and epg",
            "display_name": "TEST",
            "url": "http://streams-link"
        }
    ]
}
EOF

    mv "$TMP_FILE" "$OUTPUT_FILE"

else
    echo "> IPAudio plugin not found. Please install it and try again."
    exit 1
fi

echo "> Done."
sleep 2
exit
