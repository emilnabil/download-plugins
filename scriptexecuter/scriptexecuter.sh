#!/bin/sh

if [ -d /usr/lib/enigma2/python/Plugins/Extensions/ScriptExecuter ]; then
echo "> removing package please wait..."
sleep 3s 
rm -rf /usr/lib/enigma2/python/Plugins/Extensions/ScriptExecuter > /dev/null 2>&1

status='/var/lib/opkg/status'
package='enigma2-plugin-extensions-scriptexecuter'

if grep -q $package $status; then
opkg remove $package > /dev/null 2>&1
fi

echo "*******************************************"
echo "*             Removed Finished            *"
echo "*******************************************"
sleep 1
plugin=scriptexecuter
version=1.0
url=https://gitlab.com/eliesat/extensions/-/raw/main/scriptexecuter/scriptexecuter-1.0.tar.gz
package=/var/volatile/tmp/$plugin-$version.tar.gz

#download & install
echo "> Downloading $plugin-$version package  please wait ..."
sleep 1

wget -O $package --no-check-certificate $url
tar -xzf $package -C /
extract=$?
rm -rf $package >/dev/null 2>&1

echo ''
if [ $extract -eq 0 ]; then
echo "> $plugin-$version package installed successfully"
else

echo "> $plugin-$version package installation failed"
sleep 2
fi
  fi
exit 0
