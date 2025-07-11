#!/bin/sh

echo "> removing configuration files, please wait..."
sleep 2

# Define paths to remove
CONFIG_PATHS="
/etc/tuxbox/config
/etc/tuxbox/gosatplus
/etc/tuxbox/powercam
/etc/tuxbox/ultracam
/etc/CCcam.cfg
/usr/keys/*
"

# Remove each path silently
for path in $CONFIG_PATHS; do
    rm -rf "$path" >/dev/null 2>&1
done

echo "> done"
sleep 2
exit

