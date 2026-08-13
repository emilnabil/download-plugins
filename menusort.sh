wget -O /var/volatile/tmp/menusort_v1.0_all.ipk "https://raw.githubusercontent.com/emil237/plugins/main/menusort_v1.0_all.ipk"
sleep 2
opkg install --force-overwrite /tmp/*.ipk
sleep 
rm -f /var/volatile/tmp/menusort_v1.0_all.ipk
wait
sleep 2
exit 0
