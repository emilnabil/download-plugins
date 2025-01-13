import socket
import os
from Plugins.Plugin import PluginDescriptor
from Screens.Screen import Screen
from Components.ActionMap import ActionMap
from Components.Label import Label
from Components.MenuList import MenuList
from Components.Button import Button
from enigma import eConsoleAppContainer
from Screens.MessageBox import MessageBox

PLUGIN_ICON = "icon.png"
PLUGIN_VERSION = "2.0.0"

class InstallProgressScreen(Screen):
    skin = """
    <screen name="InstallProgressScreen" position="center,center" size="700,150" title="Installing...">
        <widget name="status" position="10,10" size="680,130" font="Regular;24" valign="center" halign="center" />
    </screen>
    """

    def __init__(self, session, command, title):
        self.session = session
        Screen.__init__(self, session)
        self.command = command
        self.title = title
        self.container = eConsoleAppContainer()
        self.container.appClosed.append(self.command_finished)
        self.container.dataAvail.append(self.command_output)
        self["status"] = Label(f"Installing: {self.title}...")
        self.run_command()

    def run_command(self):
        if self.container.execute(self.command):
            self["status"].setText(f"Failed to execute: {self.command}")

    def command_output(self, data):
        pass

    def command_finished(self, retval):
        self.session.openWithCallback(
            self.on_close_messagebox,
            MessageBox,
            f"{self.title} installation completed.",
            MessageBox.TYPE_INFO,
            timeout=5,
        )

    def on_close_messagebox(self, result):
        self.close()

class SmartAddonspanel(Screen):
    skin = """
    <screen name="SmartAddonspanel" position="left,center" size="1140,900" title="Smart Addons Panel By Emil Nabil">
        <widget name="main_menu" position="30,50" size="500,750" scrollbarMode="showOnDemand" itemHeight="60" font="Regular;40" />
        <widget name="sub_menu" position="610,50" size="500,750" scrollbarMode="showOnDemand" itemHeight="60" 
backgroundColor="#505050"
font="Regular;40" />
        <widget name="status" position="30,820" size="1080,30" font="Regular;26" halign="center" backgroundColor="#303030" />
        <widget name="key_red" position="30,860" size="260,40" font="Regular;22" halign="center" backgroundColor="#9F1313" />
        <widget name="key_green" position="310,860" size="260,40" font="Regular;22" halign="center" backgroundColor="#1F771F" />
        <widget name="key_yellow" position="590,860" size="260,40" font="Regular;22" halign="center" backgroundColor="#FFC000" />
        <widget name="key_blue" position="870,860" size="260,40" font="Regular;22" halign="center" backgroundColor="#13389F" />
        <widget name="ip_address" position="30,800" size="260,30" font="Regular;22" halign="left" foregroundColor="#FFFFFF" />
        <widget name="python_version" position="870,800" size="260,30" font="Regular;22" halign="right" foregroundColor="#FFFFFF" />
    </screen>
    """

    def __init__(self, session):
        self.session = session
        Screen.__init__(self, session)

        self.main_menu = ["Panels", "Plugins", "Media", "Tools", "Images", "Picons", "Emu", "Channels", "Key Plugins", "Multiboot Plugins", "Skins", "Bootlogo"]
        self.sub_menus = {
            "Panels": [
                ("Ajpanel", "wget https://github.com/AMAJamry/AJPanel/raw/main/installer.sh -O - | /bin/sh"),
        ("AjPanel custom menu All panels By Emil", "wget https://dreambox4u.com/emilnabil237/plugins/ajpanel/emil-panel-all.sh -O - | /bin/sh"),
        ("Panel Lite By Emil Nabil", "wget https://dreambox4u.com/emilnabil237/plugins/ajpanel/new/emil-panel-lite.sh -O - | /bin/sh"),
        ("dreamosat-downloader", "wget https://dreambox4u.com/emilnabil237/plugins/dreamosat-downloader/installer.sh -O - | /bin/sh"),
        ("Epanel", "wget https://dreambox4u.com/emilnabil237/plugins/epanel/installer.sh -O - | /bin/sh"),
        ("linuxsat-panel", "wget https://raw.githubusercontent.com/Belfagor2005/LinuxsatPanel/main/installer.sh -O - | /bin/sh"),
        ("levi45-AddonsManager", "wget https://dreambox4u.com/emilnabil237/plugins/levi45-addonsmanager/installer.sh -O - | /bin/sh"),
        ("Levi45MulticamManager", "wget https://dreambox4u.com/emilnabil237/plugins/levi45multicammanager/installer.sh -O - | /bin/sh"),
        ("SatVenusPanel", "wget https://dreambox4u.com/emilnabil237/plugins/satvenuspanel/installer.sh -O - | /bin/sh"),
        ("Tspanel", "wget https://dreambox4u.com/emilnabil237/plugins/tspanel/installer.sh -O - | /bin/sh"),
        ("TvAddon-Panel", "wget https://dreambox4u.com/emilnabil237/plugins/tvaddon/installer.sh -O - | /bin/sh"),
    ],
            "Plugins": [
                ("ArabicSavior", "wget http://dreambox4u.com/emilnabil237/plugins/ArabicSavior/installer.sh -O - | /bin/sh"),
                ("Alajre", "wget https://dreambox4u.com/emilnabil237/plugins/alajre/installer.sh -O - | /bin/sh"),
       ("Ansite", "wget https://raw.githubusercontent.com/MOHAMED19OS/Download/main/Ansite/installer.sh -O - | /bin/sh"),
       ("Athan Times", "wget https://dreambox4u.com/emilnabil237/plugins/athantimes/installer.sh -O - | /bin/sh"), 
        ("Atilehd", "wget https://dreambox4u.com/emilnabil237/plugins/atilehd/installer.sh -O - | /bin/sh"),
         ("automatic-fullbackup", "wget https://dreambox4u.com/emilnabil237/plugins/automatic-fullbackup/installer.sh -O - | /bin/sh"), 
         ("Azkar Almuslim", "wget https://dreambox4u.com/emilnabil237/plugins/azkar-almuslim/installer.sh -O - | /bin/sh"), 
         ("CFG_ZOOM_FINAL", "wget https://dreambox4u.com/emilnabil237/plugins/cfg_Zoom_Final_FIX7x/installer.sh -O - | /bin/sh"), 
         ("CiefpSettingsDownloader", "wget https://raw.githubusercontent.com/ciefp/CiefpSettingsDownloader/main/installer.sh -O - | /bin/sh"),
    ("CiefpsettingsMotor", "wget https://raw.githubusercontent.com/ciefp/CiefpsettingsMotor/main/installer.sh -O - | /bin/sh"), 
    ("Ciefp-Whitelist-Streamrelay", "wget https://raw.githubusercontent.com/ciefp/CiefpWhitelistStreamrelay/main/installer.sh -O - | /bin/sh"), 
    ("Ciefp-Settings-T2mi-Abertis", "wget https://raw.githubusercontent.com/ciefp/CiefpSettingsT2miAbertis/main/installer.sh -O - | /bin/sh"), 
 ("CHLogoChanger", "wget https://dreambox4u.com/emilnabil237/plugins/CHLogoChanger/ChLogoChanger.sh -O - | /bin/sh"),
                ("CrashLogoViewer", "wget https://dreambox4u.com/emilnabil237/plugins/crashlogviewer/install-CrashLogViewer.sh -O - | /bin/sh"),
       ("CrondManger", "wget https://github.com/emil237/download-plugins/raw/main/cronmanager.sh -O - | /bin/sh"),
       ("Epg Grabber", "wget https://raw.githubusercontent.com/ziko-ZR1/Epg-plugin/master/Download/installer.sh -O - | /bin/sh"), 
        ("Footonsat", "wget https://dreambox4u.com/emilnabil237/plugins/FootOnsat/installer.sh -O - | /bin/sh"),
        ("Footonsat-New", "wget https://gitlab.com/MOHAMED_OS/dz_store/-/raw/main/FootOnsat/online-setup -O - | /bin/sh"),
         ("FreeCCcamServer", "wget https://ia803104.us.archive.org/0/items/freecccamserver/installer.sh -O - | /bin/sh"), 
         ("HasBahCa", "wget https://dreambox4u.com/emilnabil237/plugins/HasBahCa/installer.sh -O - | /bin/sh"), 
         ("HistoryZapSelector", "wget https://dreambox4u.com/emilnabil237/plugins/historyzap/installer.sh -O - | /bin/sh"), 
         ("MoviesManager", "wget http://dreambox4u.com/emilnabil237/plugins/Transmission/MoviesManager.sh -O - | /bin/sh"),
    ("MyCam-Plugin", "wget https://dreambox4u.com/emilnabil237/plugins/mycam/installer.sh -O - | /bin/sh"), 
    ("NewVirtualkeyBoard", "wget https://raw.githubusercontent.com/fairbird/NewVirtualKeyBoard/main/installer.sh -O - | /bin/sh"), 
    ("Ozeta-Skins-Setup", "wget https://raw.githubusercontent.com/emil237/skins-enigma2/main/PLUGIN_Skin-ozeta.sh -O - | /bin/sh"), 
("Quran-karem", "wget https://dreambox4u.com/emilnabil237/plugins/quran/installer.sh -O - | /bin/sh"),
                ("RaedQuickSignal", "wget https://raw.githubusercontent.com/fairbird/RaedQuickSignal/main/installer.sh -O - | /bin/sh"),
       ("pluginmover", "wget http://dreambox4u.com/emilnabil237/plugins/pluginmover/installer.sh -O - | /bin/sh"),
       ("pluginskinmover", "wget http://dreambox4u.com/emilnabil237/plugins/pluginskinmover/installer.sh -O - | /bin/sh"), 
        ("scriptexecuter", "wget http://dreambox4u.com/emilnabil237/plugins/scriptexecuter/installer.sh -O - | /bin/sh"),
         ("servicescanupdates", "wget https://dreambox4u.com/emilnabil237/plugins/servicescanupdates/servicescanupdates.sh -O - | /bin/sh"),
         ("Sherlockmod", "wget https://raw.githubusercontent.com/emil237/sherlockmod/main/installer.sh -O - | /bin/sh"), 
         ("Simple-Zoom-Panel", "wget https://dreambox4u.com/emilnabil237/plugins/simple-zoom-panel/installer.sh -O - | /bin/sh"), 
         ("SubsSupport_1.5.8-r9", "wget https://dreambox4u.com/emilnabil237/plugins/SubsSupport/installer1.sh -O - | /bin/sh"), 
         ("SubsSupport_2.1", "wget https://dreambox4u.com/emilnabil237/plugins/SubsSupport/subssupport_2.1.sh -O - | /bin/sh"),
    ("uninstaller-Plugins", "wget http://dreambox4u.com/emilnabil237/plugins/unstaller-plugins/installer.sh -O - | /bin/sh"), 
    ("vavoo_1.15", "wget https://dreambox4u.com/emilnabil237/plugins/vavoo/installer.sh -O - | /bin/sh"), 
    ("xtraevent_3.3", "wget https://raw.githubusercontent.com/emil237/download-plugins/main/xtraevent_3.3.sh -O - | /bin/sh"), 
 ("xtraevent_4.2", "wget https://raw.githubusercontent.com/emil237/download-plugins/main/xtraEvent_4.2.sh -O - | /bin/sh"),
                ("xtraevent_4.5", "wget https://raw.githubusercontent.com/emil237/download-plugins/main/xtraEvent_4.5.sh -O - | /bin/sh"),
       ("Xtraevent_4.6", "wget https://github.com/emil237/download-plugins/raw/main/Xtraevent-v4.6.sh -O - | /bin/sh"),
       ("xtraevent_6.798", "wget https://dreambox4u.com/emilnabil237/plugins/xtraevent/xtraevent_6.798.sh -O - | /bin/sh"), 
       ("xtraevent_6.805", "wget https://dreambox4u.com/emilnabil237/plugins/xtraevent/xtraevent-6.805.sh -O - | /bin/sh"), 
        ("Zoom_1.1.2-Py3", "wget https://dreambox4u.com/emilnabil237/plugins/zoom/installer.sh -O - | /bin/sh"),
            ],
    "Media": [
        ("BouquetMakerXtream", "wget http://dreambox4u.com/emilnabil237/plugins/BouquetMakerXtream/installer.sh -O - | /bin/sh"),
        ("E2Player-MOHAMED-Os", "wget https://mohamed_os.gitlab.io/e2iplayer/online-setup  -O - | /bin/sh"),
  ("E2Player-MAXBAMBY", "wget https://gitlab.com/maxbambi/e2iplayer/-/raw/master/install-e2iplayer.sh  -O - | /bin/sh"),
  ("E2Player-ZADMARIO", "wget https://gitlab.com/zadmario/e2iplayer/-/raw/master/install-e2iplayer.sh  -O - | /bin/sh"),
        ("IptoSat", "wget https://dreambox4u.com/emilnabil237/plugins/iptosat/installer.sh  -O - | /bin/sh"),
        ("IpAudio_6.7_py2", "wget https://dreambox4u.com/emilnabil237/plugins/ipaudio/installer.sh -O - | /bin/sh"),
        ("IpAudio_7.4_py3", "wget https://dreambox4u.com/emilnabil237/plugins/ipaudio/ipaudio-7.4-ffmpeg.sh -O - | /bin/sh"),
        ("IpAudioPro", "wget https://dreambox4u.com/emilnabil237/plugins/ipaudiopro/installer.sh  -O - | /bin/sh"),
        ("JediEpgExtream", "wget https://dreambox4u.com/emilnabil237/plugins/jediepgextream/installer.sh  -O - | /bin/sh"),
        ("jedimakerxtream", "wget https://dreambox4u.com/emilnabil237/plugins/jedimakerxtream/installer.sh  -O - | /bin/sh"),
        ("multistalker", "wget https://dreambox4u.com/emilnabil237/plugins/multistalker/installer.sh -O - | /bin/sh"),
        ("MultiStalkerPro", "wget https://raw.githubusercontent.com/emilnabil/multi-stalkerpro/main/installer.sh -O - | /bin/sh"),
        ("Quarter pounder", "wget http://dreambox4u.com/emilnabil237/script/quarterpounder.sh -O - | /bin/sh"),
        ("Suptv", "wget https://raw.githubusercontent.com/emil237/suptv/main/installer.sh -O - | /bin/sh"),
        ("YouTube", "wget https://dreambox4u.com/emilnabil237/plugins/YouTube/installer.sh  -O - | /bin/sh"),
        ("xklass-iptv", "wget https://dreambox4u.com/emilnabil237/plugins/xklass/installer.sh -O - | /bin/sh"),
        ("Xtreamty", "wget https://dreambox4u.com/emilnabil237/plugins/xtreamity/installer.sh -O - | /bin/sh"),
        ("Xcpluginforever", "wget https://raw.githubusercontent.com/Belfagor2005/xc_plugin_forever/main/installer.sh -O - | /bin/sh"),
    ],
    "Tools": [   
("Wget", "opkg install wget"),
("Curl", "opkg install curl"),
("Update Enigma2 All Python", "wget https://raw.githubusercontent.com/emil237/updates-enigma/main/update-all-python.sh  -O - | /bin/sh"),
("Super Script", "wget https://dreambox4u.com/emilnabil237/script/Super_Script.sh  -O - | /bin/sh"),
("CAM-abertis-astra-sm", "wget https://dreambox4u.com/emilnabil237/script/CAM-abertis-astra.sh  -O - | /bin/sh"),
        ("FORMAT_HDD_TO-Ext4", "wget https://raw.githubusercontent.com/emil237/scripts/refs/heads/main/format-hdd.sh  -O - | /bin/sh"),
        ("Repair-Inodes-From-Hdd", "wget https://raw.githubusercontent.com/emil237/scripts/refs/heads/main/repair-hdd.sh  -O - | /bin/sh"),
        ("FIX-ipk-package-installation", "wget https://dreambox4u.com/emilnabil237/script/fix-ipk-package-installation.sh -O - | /bin/sh"),
        ("Set_Time_NTP-Google", "wget https://dreambox4u.com/emilnabil237/script/set_time.sh  -O - | /bin/sh"),
        ("Fix Softcam Atv", "wget http://updates.mynonpublic.com/oea/feed  -O - | /bin/sh"),
        ("Fix Softcam OpenPli", "wget https://raw.githubusercontent.com/emil237/download-plugins/main/softcam-support-pli.sh  -O - | /bin/sh"),
        ("Wget package Vti", "wget https://raw.githubusercontent.com/emil237/download-plugins/refs/heads/main/tool_vti-wget_1.16.3.sh  -O - | /bin/sh"),
        ("Feed OpenPicons", "wget https://dreambox4u.com/emilnabil237/script/openpicons-feed.sh -O - | /bin/sh"),
    ],
    "Images": [
        ("BlackHole-3.1.0", "wget https://dreambox4u.com/emilnabil237/images/BlackHole-3.1.0.sh  -O - | /bin/sh"),
        ("Egami-10.4", "wget https://dreambox4u.com/emilnabil237/images/egami-10.4.sh -O - | /bin/sh"),
        ("Openatv-6.4", "wget https://dreambox4u.com/emilnabil237/images/openatv-6.4.sh  -O - | /bin/sh"),
        ("Openatv-7.0", "wget https://dreambox4u.com/emilnabil237/images/openatv-7.0.sh  -O - | /bin/sh"),
        ("Openatv-7.1", "wget https://dreambox4u.com/emilnabil237/images/openatv-7.1.sh  -O - | /bin/sh"),
        ("Openatv-7.2", "wget https://dreambox4u.com/emilnabil237/images/openatv-7.2.sh -O - | /bin/sh"),
        ("Openatv-7.3", "wget https://dreambox4u.com/emilnabil237/images/openatv-7.3.sh -O - | /bin/sh"),
        ("Openatv-7.4", "wget https://dreambox4u.com/emilnabil237/images/openatv-7.4.sh -O - | /bin/sh"),
        ("Openatv-7.5", "wget https://dreambox4u.com/emilnabil237/images/openatv-7.5.sh -O - | /bin/sh"),
        ("Openatv-7.5.1", "wget https://dreambox4u.com/emilnabil237/images/openatv-7.5.1.sh -O - | /bin/sh"),
        ("OpenBlackHole-4.4", "wget https://dreambox4u.com/emilnabil237/images/openblackhole-4.4-for-vuplus-only.sh -O - | /bin/sh"),
        ("OpenBlackHole-5.0", "wget https://dreambox4u.com/emilnabil237/images/openblackhole-5.0.sh -O - | /bin/sh"),
        ("OpenBlackHole-5.1", "wget https://dreambox4u.com/emilnabil237/images/openblackhole-5.1.sh -O - | /bin/sh"),
        ("OpenBlackHole-5.2", "wget https://dreambox4u.com/emilnabil237/images/openblackhole-5.2.sh -O - | /bin/sh"),
        ("OpenBlackHole-5.3", "wget https://dreambox4u.com/emilnabil237/images/openblackhole-5.3.sh -O - | /bin/sh"),
        ("OpenBlackHole-5.4", "wget https://dreambox4u.com/emilnabil237/images/openblackhole-5.4.sh -O - | /bin/sh"),
        ("OpenDroid-7.1", "wget https://dreambox4u.com/emilnabil237/images/opendroid-7.1.sh -O - | /bin/sh"),
        ("OpenDroid-7.3", "wget https://dreambox4u.com/emilnabil237/images/opendroid-7.3.sh -O - | /bin/sh"),
        ("Openpli-7.3", "wget https://dreambox4u.com/emilnabil237/images/openpli-7.3.sh  -O - | /bin/sh"),
        ("OpenPli-8.3", "wget https://dreambox4u.com/emilnabil237/images/openpli-8.3.sh -O - | /bin/sh"),
        ("OpenPli-8.3-Time-Shift", "wget https://dreambox4u.com/emilnabil237/images/openpli-8.3-py2-TimeShift.sh -O - | /bin/sh"),
        ("OpenPli-9.0-Time-Shift", "wget https://dreambox4u.com/emilnabil237/images/openpli-9.0-py3-TimeShift.sh -O - | /bin/sh"),
        ("OpenPli-9.0", "wget https://dreambox4u.com/emilnabil237/images/openpli-9.0.sh -O - | /bin/sh"),
        ("OpenPli-develop", "wget https://dreambox4u.com/emilnabil237/images/openpli-develop.sh -O - | /bin/sh"),
        ("openspa-7.5.xxx", "wget https://dreambox4u.com/emilnabil237/images/openspa-7.5.xxx.sh  -O - | /bin/sh"),
        ("openspa-8.0.xxx", "wget https://dreambox4u.com/emilnabil237/images/openspa-8.0.xxx.sh  -O - | /bin/sh"),
        ("openspa-8.1.xxx", "wget https://dreambox4u.com/emilnabil237/images/openspa-8.1.xxx.sh  -O - | /bin/sh"),
        ("openspa-8.3.xxx", "wget https://dreambox4u.com/emilnabil237/images/openspa-8.3.xxx.sh  -O - | /bin/sh"),
        ("openspa-8.4.xxx", "wget https://dreambox4u.com/emilnabil237/images/openspa-8.4.xxx.sh  -O - | /bin/sh"),
        ("Openvix-6.4.011", "wget https://dreambox4u.com/emilnabil237/images/openvix-6.4.011.sh -O - | /bin/sh"),
        ("Openvix-6.5.001", "wget https://dreambox4u.com/emilnabil237/images/openvix-6.5.001.sh -O - | /bin/sh"),
        ("Openvix-6.6.001", "wget https://dreambox4u.com/emilnabil237/images/openvix-6.6.001.sh -O - | /bin/sh"),
        ("Openvix-6.6.004", "wget https://dreambox4u.com/emilnabil237/images/openvix-6.6.004.sh -O - | /bin/sh"),
        ("OpenVision-py2-10.3-r395", "wget https://dreambox4u.com/emilnabil237/images/openvision/OpenVision-py2-10.3-r395.sh -O - | /bin/sh"),
        ("pure2-6.5", "wget https://dreambox4u.com/emilnabil237/images/pure2-6.5.sh  -O - | /bin/sh"),
        ("pure2-7.3", "wget https://dreambox4u.com/emilnabil237/images/pure2-7.3.sh  -O - | /bin/sh"),
        ("pure2-7.4", "wget https://dreambox4u.com/emilnabil237/images/pure2-7.4.sh  -O - | /bin/sh"),
        ("VTI-15.0.02", "wget https://dreambox4u.com/emilnabil237/images/vti-15.0.02.sh -O - | /bin/sh"),
    ],
    "Picons": [
        ("intelsat_31.5w", "wget https://dreambox4u.com/emilnabil237/picons/intelsat_31.5w/installer.sh -O - | /bin/sh"),
        ("hispasat_30.0w", "wget https://dreambox4u.com/emilnabil237/picons/hispasat_30.0w/installer.sh -O - | /bin/sh"),
        ("intelsat_27.5w", "wget https://dreambox4u.com/emilnabil237/picons/intelsat_27.5w/installer.sh -O - | /bin/sh"),
        ("intelsat_24.5w", "wget https://dreambox4u.com/emilnabil237/picons/intelsat_24.5w/installer.sh -O - | /bin/sh"),
        ("ses4_22.0w", "wget https://dreambox4u.com/emilnabil237/picons/ses4_22.0w/installer.sh -O - | /bin/sh"),
        ("nss7_20.0w", "wget https://dreambox4u.com/emilnabil237/picons/nss7_20.0w/installer.sh -O - | /bin/sh"),
        ("telstar_15.0w", "wget https://dreambox4u.com/emilnabil237/picons/telstar_15.0w/installer.sh -O - | /bin/sh"),
        ("express_14w", "wget https://dreambox4u.com/emilnabil237/picons/express_14w/installer.sh -O - | /bin/sh"),
        ("express_11.0w-14.0w", "wget https://dreambox4u.com/emilnabil237/picons/express_11.0w-14.0w/installer.sh -O - | /bin/sh"),
        ("Nilesat_7W-8W", "wget https://dreambox4u.com/emilnabil237/picons/nilesat/installer.sh -O - | /bin/sh"),
        ("eutelsat_5.0w", "wget https://dreambox4u.com/emilnabil237/picons/eutelsat_5.0w/installer.sh -O - | /bin/sh"),
        ("Amos_4.0W", "wget https://dreambox4u.com/emilnabil237/picons/amos_4.0w/installer.sh -O - | /bin/sh"),
        ("abs_3.0w", "wget https://dreambox4u.com/emilnabil237/picons/abs_3.0w/installer.sh -O - | /bin/sh"),
        ("thor_0.8w", "wget https://dreambox4u.com/emilnabil237/picons/thor_0.8w/installer.sh -O - | /bin/sh"),
        ("bulgariasat_1.9e", "wget https://dreambox4u.com/emilnabil237/picons/bulgariasat_1.9e/installer.sh -O - | /bin/sh"),
        ("eutelsat_3.0e", "wget https://dreambox4u.com/emilnabil237/picons/eutelsat_3.0e/installer.sh -O - | /bin/sh"),
        ("astra_4.8e", "wget https://dreambox4u.com/emilnabil237/picons/astra_4.8e/installer.sh -O - | /bin/sh"),
        ("eutelsat_7.0e", "wget https://dreambox4u.com/emilnabil237/picons/eutelsat_7.0e/installer.sh -O - | /bin/sh"),
        ("eutelsat_9.0e", "wget https://dreambox4u.com/emilnabil237/picons/eutelsat_9.0e/installer.sh -O - | /bin/sh"),
        ("eutelsat_10.0e", "wget https://dreambox4u.com/emilnabil237/picons/eutelsat_10.0e/installer.sh -O - | /bin/sh"),
        ("hotbird_13.0e", "wget https://dreambox4u.com/emilnabil237/picons/hotbird_13.0e/installer.sh -O - | /bin/sh"),
        ("eutelsat_16.0e", "wget https://dreambox4u.com/emilnabil237/picons/eutelsat_16.0e/installer.sh -O - | /bin/sh"),
        ("astra_19.2e", "wget https://dreambox4u.com/emilnabil237/picons/astra_19.2e/installer.sh -O - | /bin/sh"),
        ("eutelsat_21.6e", "wget https://dreambox4u.com/emilnabil237/picons/eutelsat_21.6e/installer.sh -O - | /bin/sh"),
        ("astra_23.5e", "wget https://dreambox4u.com/emilnabil237/picons/astra_23.5e/installer.sh -O - | /bin/sh"),
        ("eshail_25.5e", "wget https://dreambox4u.com/emilnabil237/picons/eshail_25.5e/installer.sh -O - | /bin/sh"),
        ("badr_26.0e", "wget https://dreambox4u.com/emilnabil237/picons/badr_26.0e/installer.sh -O - | /bin/sh"),
        ("astra_28.2e", "wget https://dreambox4u.com/emilnabil237/picons/astra_28.2e/installer.sh -O - | /bin/sh"),
        ("arabsat_30.5e", "wget https://dreambox4u.com/emilnabil237/picons/arabsat_30.5e/installer.sh -O - | /bin/sh"),
        ("astra_31.5e", "wget https://dreambox4u.com/emilnabil237/picons/astra_31.5e/installer.sh -O - | /bin/sh"),
        ("intelsat_33.0e", "wget https://dreambox4u.com/emilnabil237/picons/eutelsat-intelsat_33.0e/installer.sh -O - | /bin/sh"),
        ("eutelsat_36.0e", "wget https://dreambox4u.com/emilnabil237/picons/eutelsat_36.0e/installer.sh -O - | /bin/sh"),
        ("hellas-sat_39.0e", "wget https://dreambox4u.com/emilnabil237/picons/hellas-sat_39.0e/installer.sh -O - | /bin/sh"),
        ("turksat_42.0e", "wget https://dreambox4u.com/emilnabil237/picons/turksat_42.0e/installer.sh -O - | /bin/sh"),
        ("azerspace_45.0e", "wget https://dreambox4u.com/emilnabil237/picons/azerspace_45.0e/installer.sh -O - | /bin/sh"),
        ("azerspace_46.0e", "wget https://dreambox4u.com/emilnabil237/picons/azerspace_46.0e/installer.sh -O - | /bin/sh"),
        ("turksat_50.0e_56.0e_57e", "wget https://dreambox4u.com/emilnabil237/picons/turksat_50.0e_56.0e_57e/installer.sh -O - | /bin/sh"),
        ("belintersat_51.5e", "wget https://dreambox4u.com/emilnabil237/picons/belintersat_51.5e/installer.sh -O - | /bin/sh"),
        ("turkmenalem_52.0e", "wget https://dreambox4u.com/emilnabil237/picons/turkmenalem_52.0e/installer.sh -O - | /bin/sh"),
        ("alyahsat_52.5e", "wget https://dreambox4u.com/emilnabil237/picons/alyahsat_52.5e/installer.sh -O - | /bin/sh"),
        ("express_53.0e", "wget https://dreambox4u.com/emilnabil237/picons/express_53.0e/installer.sh -O - | /bin/sh"),
        ("yamal_54.9e", "wget https://dreambox4u.com/emilnabil237/picons/gsat-yamal_54.9e/installer.sh -O - | /bin/sh"),
        ("intelsat_60.0e_66.0e_68.0e", "wget https://dreambox4u.com/emilnabil237/picons/intelsat_60.0e_66.0e_68.0e/installer.sh -O - | /bin/sh"),
        ("intelsat_62.0e", "wget https://dreambox4u.com/emilnabil237/picons/intelsat_62.0e/installer.sh -O - | /bin/sh"),
        ("eutelsat_70.0e_74.9e_75.0e", "wget https://dreambox4u.com/emilnabil237/picons/eutelsat_70.0e_74.9e_75.0e/installer.sh -O - | /bin/sh"),
        ("Intelsat_72.1e", "wget https://dreambox4u.com/emilnabil237/picons/Intelsat_72.1e/installer.sh -O - | /bin/sh"),
        ("abs_75.0e", "wget https://dreambox4u.com/emilnabil237/picons/abs_75.0e/installer.sh -O - | /bin/sh"),
        ("picons-other", "wget https://raw.githubusercontent.com/emil237/picon-other/main/installer.sh -O - | /bin/sh"),
        ("Chocholousek-Picons", "wget https://github.com/s3n0/e2plugins/raw/master/ChocholousekPicons/online-setup -O - | /bin/sh"),
    ],
    "Emu": [
        ("Cccam", "wget https://dreambox4u.com/emilnabil237/emu/installer-cccam.sh  -O - | /bin/sh"),
        ("gosatplus-ncam", "wget https://dreambox4u.com/emilnabil237/emu/installer-gosatplus-ncam.sh  -O - | /bin/sh"),
        ("gosatplus-oscam", "wget https://dreambox4u.com/emilnabil237/emu/installer-gosatplus-oscam.sh  -O - | /bin/sh"),
        ("gosatplus_v3_arm", "wget http://e2.gosatplus.com/Plugin/V3/arm-openpli-installer_py3_v3.sh  -O - | /bin/sh"),
        ("gosatplus_v3_mips", "wget http://e2.gosatplus.com/Plugin/V3/mips-openpli-installer_py3_v3.sh  -O - | /bin/sh"),
        ("gosatplus_v3_Fix", "wget http://e2.gosatplus.com/Plugin/V3/GosatPlusPluginFixPy.sh  -O - | /bin/sh"),
        ("Hold-flag-ncam", "opkg flag hold enigma2-plugin-softcams-ncam"),
        ("Hold-flag-Oscam", "opkg flag hold enigma2-plugin-softcams-oscam"),
        ("Ncam", "wget https://dreambox4u.com/emilnabil237/emu/installer-ncam.sh -O - | /bin/sh"),
        ("Oscam", "wget https://dreambox4u.com/emilnabil237/emu/installer-oscam.sh  -O - | /bin/sh"),
        ("Oscam-11.726-by-lenuxsat", "wget https://dreambox4u.com/emilnabil237/emu/oscam-by-lenuxsat/installer.sh  -O - | /bin/sh"),
        ("oscamicam", "wget https://dreambox4u.com/emilnabil237/emu/installer-oscamicam.sh  -O - | /bin/sh"),
        ("powercam_v2-icam-arm", "wget https://dreambox4u.com/emilnabil237/emu/powercam/installer.sh  -O - | /bin/sh"),
        ("powercam-Ncam", "wget https://dreambox4u.com/emilnabil237/emu/installer-powercam-ncam.sh  -O - | /bin/sh"),
        ("powercam-Oscam", "wget https://dreambox4u.com/emilnabil237/emu/installer-powercam-oscam.sh  -O - | /bin/sh"),
        ("Restore-flag-ncam", "opkg flag user enigma2-plugin-softcams-ncam"),
        ("Restore-flag-oscam", "opkg flag user enigma2-plugin-softcams-oscam"),
        ("Revcam-Ncam", "wget https://dreambox4u.com/emilnabil237/emu/installer-revcam-ncam.sh  -O - | /bin/sh"),
        ("Revcam-Oscam", "wget https://dreambox4u.com/emilnabil237/emu/installer-revcam-oscam.sh  -O - | /bin/sh"),
        ("Revcam", "wget https://dreambox4u.com/emilnabil237/emu/installer-revcam.sh  -O - | /bin/sh"),
        ("Supcam-Ncam", "wget https://dreambox4u.com/emilnabil237/emu/installer-supcam-ncam.sh  -O - | /bin/sh"),
        ("Supcam-Oscam", "wget https://dreambox4u.com/emilnabil237/emu/installer-supcam-oscam.sh  -O - | /bin/sh"),
        ("Ultracam-Ncam", "wget https://dreambox4u.com/emilnabil237/emu/installer-ultracam-ncam.sh  -O - | /bin/sh"),
        ("Ultracam-Oscam", "wget https://dreambox4u.com/emilnabil237/emu/installer-ultracam-oscam.sh  -O - | /bin/sh"),
        ("Ultracam", "wget https://dreambox4u.com/emilnabil237/emu/installer-ultracam.sh  -O - | /bin/sh"),
    ],
    "Channels": [
        ("Elsafty-Tv-Radio-Steaming", "wget https://dreambox4u.com/emilnabil237/settings/elsafty/installer.sh -O - | /bin/sh"),
        ("Khaled Ali", "wget https://raw.githubusercontent.com/emilnabil/channel-khaled/main/installer.sh -qO - | /bin/sh"),
        ("Mohamed Goda", "wget https://raw.githubusercontent.com/emilnabil/channel-mohamed-goda/main/installer.sh  -O - | /bin/sh"),
        ("Emil Nabil", "wget https://raw.githubusercontent.com/emilnabil/channel-emil-nabil/main/installer.sh -O - | /bin/sh"),
        ("Mohamed Os", "wget https://gitlab.com/MOHAMED_OS/dz_store/-/raw/main/Settings_Enigma2/online-setup | bash"),
        ("Tarek Ashry", "wget https://raw.githubusercontent.com/emilnabil/channel-tarek-ashry/main/installer.sh -qO - | /bin/sh"),
    ],
    "Key Plugins": [
        ("BissFeedAutoKey", "wget https://raw.githubusercontent.com/emilnabil/bissfeed-autokey/main/installer.sh  -O - | /bin/sh"),
        ("feeds-finder", "wget https://dreambox4u.com/emilnabil237/plugins/feeds-finder/installer.sh  -O - | /bin/sh"),
        ("KeyAdder", "wget https://raw.githubusercontent.com/fairbird/KeyAdder/main/installer.sh -O - | /bin/sh"),
    ],
    "Multiboot Plugins": [
        ("EgamiBoot_10.5", "wget https://raw.githubusercontent.com/emil237/egamiboot/refs/heads/main/installer.sh  -O - | /bin/sh"),
        ("EgamiBoot_10.6", "wget https://raw.githubusercontent.com/emil237/egamiboot/refs/heads/main/egamiboot-10.6.sh -O - | /bin/sh"),
        ("Neoboot_9.65", "wget https://dreambox4u.com/emilnabil237/plugins/neoboot-v9.65/iNB.sh  -O - | /bin/sh"),
        ("Neoboot_9.60", "wget https://dreambox4u.com/emilnabil237/plugins/neoboot-v9.60/iNB.sh  -O - | /bin/sh"),
        ("Neoboot_9.58", "wget https://dreambox4u.com/emilnabil237/plugins/neoboot-v9.58/iNB.sh -O - | /bin/sh"),
        ("Neoboot_9.54", "wget https://raw.githubusercontent.com/emil237/neoboot_9.54/main/installer.sh  -O - | /bin/sh"),
        ("OpenMultiboot_1.3", "wget https://raw.githubusercontent.com/emil237/openmultiboot/main/installer.sh  -O - | /bin/sh"),
        ("OpenMultiboot-E2turk", "wget https://raw.githubusercontent.com/e2TURK/omb-enhanced/main/install.sh  -O - | /bin/sh"),
        ("Multiboot-FlashOnline", "wget https://raw.githubusercontent.com/emil237/download-plugins/main/multiboot-flashonline.sh -O - | /bin/sh"),
    ],
    "Skins": [
        ("Aglare-FHD for Atv-Spa-Egami", "wget https://dreambox4u.com/emilnabil237/skins/script/skins-aglare-fhd.sh -O - | /bin/sh"),
        ("Aglare-FHD for Pli-OBH-Vix", "wget https://dreambox4u.com/emilnabil237/skins/script/skins-aglare-fhd-pli.sh -O - | /bin/sh"),
        ("XDreamy-FHD", "wget https://raw.githubusercontent.com/Insprion80/Skins/main/xDreamy/installer.sh -O - | /bin/sh"),
    ],
    "Bootlogo": [
        ("BootlogoSwapper Atv", "wget http://dreambox4u.com/emilnabil237/script/bootlogoswapper-Atv.sh  -O - | /bin/sh"),
        ("Bootlogo-PURE2", "wget http://dreambox4u.com/emilnabil237/script/bootLogoswapper-Pure2.sh  -O - | /bin/sh"),
        ("BootlogoSwapper Christmas", "wget http://dreambox4u.com/emilnabil237/script/bootlogoswapper-christmas.sh -O - | /bin/sh"),
        ("BootlogoSwapper Pli", "wget http://dreambox4u.com/emilnabil237/script/bootlogoswapper-pli.sh -O - | /bin/sh"),
        ("BootlogoSwapper OpenBH", "wget http://dreambox4u.com/emilnabil237/script/bootlogoswapper-OpenBH.sh  -O - | /bin/sh"),
        ("BootlogoSwapper Egami", "wget http://dreambox4u.com/emilnabil237/script/bootLogoswapper-Egami.sh -O - | /bin/sh"),
        ("BootlogoSwapper OpenVix", "wget http://dreambox4u.com/emilnabil237/script/bootlogoswapper-OpenVix.sh  -O - | /bin/sh"),
        ("BootlogoSwapper Kids", "wget http://dreambox4u.com/emilnabil237/script/bootlogoswapper-kids.sh -O - | /bin/sh"),
        ("BootlogoSwapper Ramadan", "wget http://dreambox4u.com/emilnabil237/script/bootlogo-swapper-ramadan.sh  -O - | /bin/sh"),
        ("BootlogoSwapper Eid-Aldha", "wget http://dreambox4u.com/emilnabil237/script/bootlogoswaper-Eid-Aldha.sh -O - | /bin/sh"),
        ("BootlogoSwapper V2.1", "wget http://dreambox4u.com/emilnabil237/script/BootlogoSwapper_v2.1.sh  -O - | /bin/sh"),
        ("BootlogoSwapper V2.3", "wget http://dreambox4u.com/emilnabil237/script/BootlogoSwapper_v2.3.sh  -O - | /bin/sh"),
    ],
}
        self.current_sub_menu = []
        self.focus = "main_menu"

        self["main_menu"] = MenuList(self.main_menu)
        self["sub_menu"] = MenuList(self.current_sub_menu)
        self["status"] = Label("Select a category to view items")
        self["key_red"] = Button("Exit")
        self["key_green"] = Button("Select")
        self["key_yellow"] = Button("Update Plugin")
        self["key_blue"] = Button("Restart Enigma2")
        self["ip_address"] = Label(self.get_router_ip())
        self["python_version"] = Label(self.get_python_version())

        self["actions"] = ActionMap(
            ["OkCancelActions", "DirectionActions", "ColorActions"],
            {
                "ok": self.handle_ok,
                "left": self.focus_main_menu,
                "right": self.focus_sub_menu,
                "red": self.close,
                "green": self.execute_item,
                "yellow": self.update_plugin,
                "blue": self.restart_enigma2,
                "up": self.navigate_up,
                "down": self.navigate_down,
            },
            -1,
        )

        self["main_menu"].onSelectionChanged.append(self.on_main_menu_selection_changed)

    def focus_main_menu(self):
        self.focus = "main_menu"
        self["main_menu"].selectionEnabled(1)
        self["sub_menu"].selectionEnabled(0)

    def focus_sub_menu(self):
        if self.current_sub_menu:
            self.focus = "sub_menu"
            self["main_menu"].selectionEnabled(0)
            self["sub_menu"].selectionEnabled(1)

    def handle_ok(self):
        if self.focus == "main_menu":
            self.load_sub_menu()
        elif self.focus == "sub_menu":
            self.execute_item()

    def load_sub_menu(self):
        selected = self["main_menu"].getCurrent()
        if selected and selected in self.sub_menus:
            self.current_sub_menu = [item[0] for item in self.sub_menus[selected]]
            self["sub_menu"].setList(self.current_sub_menu)
            self["status"].setText(f"Selected category: {selected}")
            self.focus_sub_menu()

    def on_main_menu_selection_changed(self):
        selected = self["main_menu"].getCurrent()
        if selected and selected in self.sub_menus:
            self.current_sub_menu = [item[0] for item in self.sub_menus[selected]]
            self["sub_menu"].setList(self.current_sub_menu)
            self["status"].setText(f"Showing items for: {selected}")
        else:
            self.current_sub_menu = []
            self["sub_menu"].setList(self.current_sub_menu)
            self["status"].setText("No items available for this category")

    def navigate_up(self):
        if self.focus == "main_menu":
            self["main_menu"].up()
        elif self.focus == "sub_menu":
            self["sub_menu"].up()

    def navigate_down(self):
        if self.focus == "main_menu":
            self["main_menu"].down()
        elif self.focus == "sub_menu":
            self["sub_menu"].down()

    def execute_item(self):
        if self.focus == "sub_menu":
            selected = self["sub_menu"].getCurrent()
            if selected:
                for item in self.sub_menus.get(self["main_menu"].getCurrent(), []):
                    if item[0] == selected:
                        command = item[1]
                        self.session.open(InstallProgressScreen, command, selected)
                        break

    def update_plugin(self):
        update_command = "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/SmartAddonspanel/smart-Panel.sh -O - | /bin/sh"
        self.session.open(InstallProgressScreen, update_command, "Update Plugin")

    def restart_enigma2(self):
        os.system("killall -9 enigma2")

    def get_router_ip(self):
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(("8.8.8.8", 80))
            ip = s.getsockname()[0]
            s.close()
            return ip
        except socket.error:
            return "IP not available"

    def get_python_version(self):
        return f"Python {os.sys.version.split()[0]}"

def Plugins(**kwargs):
    return [
        PluginDescriptor(
            name="Smart Addons Panel",
            description="Manage plugins and tools",
            where=PluginDescriptor.WHERE_PLUGINMENU,
            icon=PLUGIN_ICON,
            fnc=lambda session, **kwargs: session.open(SmartAddonspanel),
        ),
    ]



