#!/bin/sh

echo "> removing emus please wait..."
sleep 3

# Kill running processes
for file in OSCam Ncam powercam ncam oscam; do
  killall -9 $file >/dev/null 2>&1
  killall -9 /usr/bin/cam/$file >/dev/null 2>&1
done

sleep 3

# Remove emu files from multiple paths
for file in OSCam oscam ncam Ncam powercam oscamicam CCcam; do
  rm -rf /usr/camd/${file}* >/dev/null 2>&1
  rm -rf /usr/emu/${file}* >/dev/null 2>&1
  rm -rf /usr/scr/${file}* >/dev/null 2>&1
  rm -rf /usr/scr/cam/${file}* >/dev/null 2>&1
  rm -rf /usr/softcams/${file}* >/dev/null 2>&1
  rm -rf /var/emu/${file}* >/dev/null 2>&1
  rm -rf /var/scr/${file}* >/dev/null 2>&1
  rm -rf /usr/bin/${file}* >/dev/null 2>&1
  rm -rf /usr/bin/cam/${file}* >/dev/null 2>&1
done

sleep 3

# Remove scripts and config files
rm -rf /etc/ncam* >/dev/null 2>&1
rm -rf /usr/camscript/Ncam* >/dev/null 2>&1
rm -rf /usr/script/*cam.sh >/dev/null 2>&1
rm -rf /usr/script/*em.sh >/dev/null 2>&1
rm -rf /usr/camscript/*cam.sh >/dev/null 2>&1
rm -rf /usr/emu_scripts/EGcam* >/dev/null 2>&1
rm -rf /etc/init.d/softcam* >/dev/null 2>&1
rm -rf /usr/emu/start/*emu >/dev/null 2>&1
rm -rf /usr/emuscript/*em.sh >/dev/null 2>&1
rm -rf /usr/LTCAM/*ncam.sh >/dev/null 2>&1
rm -rf /usr/script/cam/*[Oo][Ss]cam.sh >/dev/null 2>&1
rm -rf /usr/script/cam/*[Nn]cam.sh >/dev/null 2>&1
rm -rf /usr/script/*emu >/dev/null 2>&1
rm -rf /etc/*emu.emu >/dev/null 2>&1
rm -rf /etc/cam.d/*[Oo][Ss]cam.sh >/dev/null 2>&1
rm -rf /etc/cam.d/*[Nn]cam.sh >/dev/null 2>&1

sleep 3

# Remove packages
for pkg in \
  enigma2-plugin-softcams-gosatplusv2-oscam \
  enigma2-plugin-softcams-oscam \
  enigma2-plugin-softcams-oscamicam \
  enigma2-plugin-softcams-powercam-oscam \
  enigma2-plugin-softcams-supcam-oscam \
  enigma2-plugin-softcams-ncam \
  enigma2-plugin-softcams-revcamv2-ncam \
  enigma2-plugin-softcams-supcam-ncam \
  enigma2-plugin-softcams-powercam-ncam \
  enigma2-plugin-softcams-gosatplusv2-ncam \
  enigma2-plugin-softcams-gosatplus2 \
  enigma2-plugin-softcams-powercam \
  enigma2-plugin-softcams-revcamv2 \
  enigma2-softcams-cccam-images \
  enigma2-softcams-cccam \
  enigma2-plugin-softcams-oscamicamnew \
  enigma2-plugin-softcams-oscam-emu-levi45 \
  enigma2-softcams-oscam-all-images; do
  opkg remove --force-depends $pkg >/dev/null 2>&1
done

echo "> done"
sleep 3

echo "> removing config files please wait..."
sleep 3

rm -rf /etc/tuxbox/config >/dev/null 2>&1
rm -rf /etc/tuxbox/gosatplus >/dev/null 2>&1
rm -rf /etc/tuxbox/powercam >/dev/null 2>&1
rm -rf /etc/tuxbox/ultracam >/dev/null 2>&1
rm -rf /etc/CCcam.cfg >/dev/null 2>&1
rm -rf /usr/keys/* >/dev/null 2>&1

echo "> done"
sleep 3
exit
