#!/bin/sh

umount /dev/sda1 

e2fsck -f -y -v -C 0 '/dev/sda1' 

resize2fs -p '/dev/sda1' 

mount /dev/sda1 /media/hdd

exit