#!/bin/sh

if [ ! -f /etc/resolv-backup.conf ]; then
    grep "^nameserver" /etc/resolv.conf > /etc/resolv-backup.conf
fi

cat > /etc/resolv.conf <<EOF
nameserver 76.76.19.19
nameserver 76.223.122.150
EOF

echo "> done"
echo "> your device will restart now, please wait..."
sleep 3

killall enigma2 || killall -9 enigma2


