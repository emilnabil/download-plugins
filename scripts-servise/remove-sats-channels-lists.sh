#!/bin/sh

echo "> removing sats & channels lists please wait..."
sleep 3

echo "> your device will restart now please wait..."
sleep 3
init 4 && sleep 1 && rm -f /etc/enigma2/*.bak && rm -f /etc/enigma2/*.sh > /dev/null 2>&1 && rm -f /etc/enigma2/blacklist > /dev/null 2>&1 && rm -f /etc/enigma2/*.del > /dev/null 2>&1 && rm -f /etc/enigma2/lamedb > /dev/null 2>&1 && rm -f /etc/enigma2/*.tv > /dev/null 2>&1 && rm -f /etc/enigma2/*.radio> /dev/null 2>&1 && rm -f /etc/enigma2/whitelist > /dev/null 2>&1 && sleep 1 && init 3