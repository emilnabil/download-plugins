#!/bin/sh

if [ ! -f /etc/resolv-backup.conf ]; then
    grep "^nameserver" /etc/resolv.conf > /etc/resolv-backup.conf
fi

cat > /etc/resolv.conf <<EOF
nameserver 1.1.1.1
nameserver 1.0.0.1
EOF

echo "> done"
echo "> your device will restart now, please wait..."
sleep 3

killall enigma2 || killall -9 enigma2


