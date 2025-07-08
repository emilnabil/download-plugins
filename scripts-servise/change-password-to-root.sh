#!/bin/sh

init 4

echo -e "root\nroot" | passwd root

sleep 4

init 3

exit 0

