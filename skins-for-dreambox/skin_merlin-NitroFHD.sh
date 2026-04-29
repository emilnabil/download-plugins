#!/bin/bash
#
##comand=wget https://github.com/emilnabil/download-plugins/raw/refs/heads/main/skins-for-dreambox/skin_merlin-NitroFHD.sh -O - | /bin/sh
#####################

echo "Installing required packages (optional)..."
apt-get install -y wget curl tar enigma2 enigma2-plugin-skincomponents-cover enigma2-plugin-skincomponents-reftomoviename enigma2-plugin-skincomponents-eventposition enigma2-plugin-skincomponents-eventlist enigma2-plugin-skincomponents-reftopiconname enigma2-plugin-skincomponents-runningtext enigma2-plugin-systemplugins-weathercomponenthandler enigma2-plugin-skincomponents-weathercomponent 

cd /tmp || exit 1

echo "Downloading plugin package..."
curl -kL "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/skins-for-dreambox/skin_merlin-NitroFHD.tar.gz" -o /tmp/skin_merlin-NitroFHD.tar.gz
if [ $? -ne 0 ]; then
    echo "✖ Download failed!"
    exit 1
fi

echo "Installing package..."
tar -xzf /tmp/skin_merlin-NitroFHD.tar.gz -C /
if [ $? -ne 0 ]; then
    echo "✖ Extraction failed!"
    exit 1
fi

echo "Cleaning up..."
rm -f /tmp/skin_merlin-NitroFHD.tar.gz

echo ""
echo "✅ Installation complete!"
echo ">>>>>>>>>>>>>>>>> DONE <<<<<<<<<<<<<<<<<"
sleep 2
exit 0








