#!/bin/sh

> /etc/resolv.conf
if [ -f /etc/resolv-backup.conf ] 
then
grep "nameserver.*" /etc/resolv-backup.conf >> /etc/resolv.conf
fi

echo "> done
> your device will restart now please wait..."; sleep 3s; killall -9 enigma2