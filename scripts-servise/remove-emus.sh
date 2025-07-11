#!/bin/sh

echo "> Removing emus, please wait..."
sleep 3

for file in OSCam* Ncam* powercam ncam oscam; do
    killall -9 "$file" >/dev/null 2>&1
    killall -9 /usr/bin/"$file" >/dev/null 2>&1
    killall -9 /usr/bin/cam/"$file" >/dev/null 2>&1
done

sleep 3

for file in OSCam* oscam* ncam* Ncam* powercam* oscamicam* CCcam*; do
    rm -rf /usr/camd/$file >/dev/null 2>&1
    rm -rf /usr/emu/$file >/dev/null 2>&1
    rm -rf /usr/scr/$file >/dev/null 2>&1
    rm -rf /usr/scr/cam/$file >/dev/null 2>&1
    rm -rf /usr/softcams/$file >/dev/null 2>&1
    rm -rf /var/emu/$file >/dev/null 2>&1
    rm -rf /var/scr/$file >/dev/null 2>&1
    rm -rf /usr/bin/$file >/dev/null 2>&1
    rm -rf /usr/bin/cam/$file >/dev/null 2>&1
done

sleep 3

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
rm -rf /usr/script/cam/*Oscam.sh >/dev/null 2>&1
rm -rf /usr/script/cam/*OSCam.sh >/dev/null 2>&1
rm -rf /usr/script/cam/*OScam.sh >/dev/null 2>&1
rm -rf /usr/script/cam/*ncam.sh >/dev/null 2>&1
rm -rf /usr/script/cam/*Ncam.sh >/dev/null 2>&1
rm -rf /usr/script/cam/*NCam.sh >/dev/null 2>&1
rm -rf /usr/script/*emu >/dev/null 2>&1
rm -rf /etc/*emu.emu >/dev/null 2>&1
rm -rf /etc/cam.d/*Oscam.sh >/dev/null 2>&1
rm -rf /etc/cam.d/*OSCam.sh >/dev/null 2>&1
rm -rf /etc/cam.d/*OScam.sh >/dev/null 2>&1
rm -rf /etc/cam.d/*ncam.sh >/dev/null 2>&1
rm -rf /etc/cam.d/*Ncam.sh >/dev/null 2>&1
rm -rf /etc/cam.d/*NCam.sh >/dev/null 2>&1

sleep 3

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
    enigma2-softcams-oscam-all-images
do
    opkg remove --force-depends "$pkg" >/dev/null 2>&1
done

echo "> Done."
sleep 3
exit 0

