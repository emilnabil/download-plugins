#!/bin/sh

echo "> removing scripts please wait..."
sleep 3

rm -rf /usr/script/* > /dev/null 2>&1

rm -rf /usr/scripts/* > /dev/null 2>&1

rm -rf /etc/cron/scripts/* > /dev/null 2>&1

rm -rf /usr/emu_scripts/* > /dev/null 2>&1

echo "> done"
sleep 3
exit
