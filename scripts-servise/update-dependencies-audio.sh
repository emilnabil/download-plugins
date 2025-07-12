#!/bin/sh

if [ -f /etc/opkg/opkg.conf ]; then
    install='opkg install'
elif [ -f /etc/apt/apt.conf ]; then
    install='apt-get install'
fi

$install gstreamer1.0-plugins-good gstreamer1.0-plugins-base gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly alsa-conf alsa-plugins alsa-state enigma2 libasound2 libc6 libgcc1 libstdc++6 

#check python version
python=$(python -c "import platform; print(platform.python_version())")
sleep 1;
case $python in 
2.7.18)
$install libavcodec58 libavformat58 libpython2.7-1.0
;;
3.9.9)
$install libavcodec58  libavformat58 libpython3.9-1.0
;;
3.10.0|3.10.1|3.10.2|3.10.3|3.10.4|3.10.5|3.10.6)
$install libavcodec60  libavformat60 libpython3.10-1.0
;;
3.11.0|3.11.1|3.11.2|3.11.3|3.11.4|3.11.5|3.11.6)
$install libavcodec60  libavformat60 libpython3.11-1.0
;;
3.12.0|3.12.1|3.12.2|3.12.3|3.12.4|3.12.5|3.12.6)
$install libavcodec60  libavformat60 libpython3.12-1.0
;;
*)
echo ""
sleep 3
;;
esac
exit
