#!/bin/sh

dd if=/dev/zero of=/media/hdd/swapfile bs=1024 count=1024k 
mkswap /media/hdd/swapfile 
chmod 0777 /media/hdd/swapfile 
swapon /media/hdd/swapfile 

echo -e "/media/hdd/swapfile \tswap \tswap \tdefaults \t0 \t0" >> /etc/fstab