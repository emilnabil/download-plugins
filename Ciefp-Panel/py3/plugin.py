import os
import urllib.request
from Plugins.Plugin import PluginDescriptor
from Screens.Screen import Screen
from Components.ActionMap import ActionMap
from Components.Label import Label
from Components.MenuList import MenuList
from Components.Button import Button
from enigma import eConsoleAppContainer

PLUGIN_VERSION = "2.0"
PLUGIN_NAME = "CiefpsettingsPanel"
ICON_PIXMAP = "/usr/lib/enigma2/python/Plugins/Extensions/CiefpsettingsPanel/icon1.png"
ICON_PATH = "/usr/lib/enigma2/python/Plugins/Extensions/CiefpsettingsPanel/icon.png"

PLUGIN_FILE_URL = "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/Ciefp-Panel/py3/plugin.py"
LOCAL_PLUGIN_FILE_PATH = "/usr/lib/enigma2/python/Plugins/Extensions/CiefpsettingsPanel/plugin.py"

PLUGINS_LIST = {
    "############ ( PANELS ) ############": "", 
"Ajpanel": "wget https://raw.githubusercontent.com/biko-73/AjPanel/main/installer.sh -O - | /bin/sh",
    "Aj Panel custom menu All panels By Emil": "wget https://dreambox4u.com/emilnabil237/plugins/ajpanel/emil-panel-all.sh -O - | /bin/sh",
    "Panel Lite By Emil Nabil": "wget https://dreambox4u.com/emilnabil237/plugins/ajpanel/new/emil-panel-lite.sh -O - | /bin/sh",
    "ElieSat Panel": "wget -q --no-check-certificate https://gitlab.com/eliesat/extensions/-/raw/main/ajpanel/eliesatpanel.sh -O - | /bin/sh",
   "dreamosat-downloader": "wget https://dreambox4u.com/emilnabil237/plugins/dreamosat-downloader/installer.sh  -O - | /bin/sh",
     "Epanel": "wget https://dreambox4u.com/emilnabil237/plugins/epanel/installer.sh  -O - | /bin/sh", 
    "ONEupdater": "wget https://raw.githubusercontent.com/Sat-Club/ONEupdaterE2/main/installer.sh -O - | /bin/sh",
    "linuxsat-panel": "wget https://dreambox4u.com/emilnabil237/plugins/linuxsat-panel/installer.sh -O - |/bin/sh",
  "levi45-AddonsManager": "wget https://dreambox4u.com/emilnabil237/plugins/levi45-addonsmanager/installer.sh -O - |/bin/sh",
  "Levi45MulticamManager": "wget https://dreambox4u.com/emilnabil237/plugins/levi45multicammanager/installer.sh -O - |/bin/sh",
    "SatVenusPanel": "wget https://dreambox4u.com/emilnabil237/plugins/satvenuspanel/installer.sh -O - |/bin/sh",
    "Tspanel": "wget https://dreambox4u.com/emilnabil237/plugins/tspanel/installer.sh -O - |/bin/sh",
    "TvAddon-Panel": "wget https://dreambox4u.com/emilnabil237/plugins/tvaddon/installer.sh -O - |/bin/sh", 

 "############ ( MULTIBOOT ) ############": "", 
"EgamiBoot": "wget https://raw.githubusercontent.com/emil237/egamiboot/refs/heads/main/installer.sh  -O - | /bin/sh",
"EgamiBoot_10.6": "wget https://raw.githubusercontent.com/emil237/egamiboot/refs/heads/main/egamiboot-10.6.sh -O - | /bin/sh",
"Neoboot_v9.65": "wget https://dreambox4u.com/emilnabil237/plugins/neoboot-v9.65/iNB.sh  -O - | /bin/sh",
"Neoboot_v9.60": "wget https://dreambox4u.com/emilnabil237/plugins/neoboot-v9.60/iNB.sh  -O - | /bin/sh",
"Neoboot_v9.58": "wget https://dreambox4u.com/emilnabil237/plugins/neoboot-v9.58/iNB.sh  -O - | /bin/sh",
"Neoboot_v9.54": "wget https://raw.githubusercontent.com/emil237/neoboot_9.54/main/installer.sh  -O - | /bin/sh",
"OpenMultiboot_1.3": "wget https://raw.githubusercontent.com/emil237/openmultiboot/main/installer.sh  -O - | /bin/sh",
"OpenMultiboot-E2turk-1.3": "wget https://raw.githubusercontent.com/e2TURK/omb-enhanced/main/install.sh  -O - | /bin/sh", 

 "############ (CHANNELS) ############": "",  "Elsafty-Tv-Radio-Steaming": "wget https://dreambox4u.com/emilnabil237/settings/elsafty/installer.sh -O - | /bin/sh", "Channels Emil": "wget https://raw.githubusercontent.com/emilnabil/channel-emil-nabil/main/installer.sh -O - | /bin/sh", 

 "############ ( PLUGINS ) ############": "", "CiefpSettingsDownloader": "wget -q --no-check-certificate https://raw.githubusercontent.com/ciefp/CiefpSettingsDownloader/main/installer.sh -O - | /bin/sh",
    "CiefpsettingsMotor": "wget https://raw.githubusercontent.com/ciefp/CiefpsettingsMotor/main/installer.sh -O - | /bin/sh", "CiefpWhitelistStreamrelay": "wget -q --no-check-certificate https://raw.githubusercontent.com/ciefp/CiefpWhitelistStreamrelay/main/installer.sh -O - | /bin/sh", "CiefpSettingsT2miAbertis": "wget -q --no-check-certificate https://raw.githubusercontent.com/ciefp/CiefpSettingsT2miAbertis/main/installer.sh -O - | /bin/sh",
    "ArabicSavior": "wget http://dreambox4u.com/emilnabil237/plugins/ArabicSavior/installer.sh  -O - | /bin/sh",
    "Alajre": "wget https://dreambox4u.com/emilnabil237/plugins/alajre/installer.sh -qO - | /bin/sh",
    "AthanTimes": "wget https://dreambox4u.com/emilnabil237/plugins/athantimes/installer.sh -O - | /bin/sh",
    "Ansite": "wget http://dreambox4u.com/emilnabil237/plugins/ansite/installer.sh -qO - | /bin/sh",
    "Quran-karem": "wget https://dreambox4u.com/emilnabil237/plugins/quran/installer.sh -qO - | /bin/sh",
    "E2m3u2bouquet": "wget https://dreambox4u.com/emilnabil237/plugins/e2m3u2bouquet/installer.sh -O - | /bin/sh",
    "Epg Grabber": "wget https://raw.githubusercontent.com/ziko-ZR1/Epg-plugin/master/Download/installer.sh -O - | /bin/sh",
    "FootOnsat": "wget https://dreambox4u.com/emilnabil237/plugins/FootOnsat/installer.sh -O - | /bin/sh",
    "E2iplayer": "wget -qO- --no-check-certificate https://mohamed_os.gitlab.io/e2iplayer/online-setup | bash",
    "ChocholousekPicons": "https://github.com/s3n0/e2plugins/raw/master/ChocholousekPicons/online-setup -qO - | bash -s install",
    "CrashLogViewer": "wget https://dreambox4u.com/emilnabil237/plugins/crashlogviewer/install-CrashLogViewer.sh -qO - | /bin/sh",
    "HistoryZapSelector": "wget https://dreambox4u.com/emilnabil237/plugins/historyzap/installer.sh -O - | /bin/sh",
    "IptoSat": "wget https://dreambox4u.com/emilnabil237/plugins/iptosat/installer.sh -qO - | /bin/sh",
    "IpAudio_6.7 Py2": "wget -q --no-check-certificate https://dreambox4u.com/emilnabil237/plugins/ipaudio/installer.sh -O - | /bin/sh",
    "IpAudio_7.4 Py3": "wget -q --no-check-certificate https://dreambox4u.com/emilnabil237/plugins/ipaudio/ipaudio-7.4-ffmpeg.sh -O - | /bin/sh",
    "IpAudioPro": "wget -q --no-check-certificate https://dreambox4u.com/emilnabil237/plugins/ipaudiopro/installer.sh -O - | /bin/sh",
    "JediEpgXtream": "wget https://dreambox4u.com/emilnabil237/plugins/jediepgextream/installer.sh -O - | /bin/sh",
   "Multi-Stalker": "wget https://dreambox4u.com/emilnabil237/plugins/multistalker/installer.sh -O - | /bin/sh",
    "Multistalker Pro": "wget -q --no-check-certificate https://dreambox4u.com/emilnabil237/plugins/MultiStalkerPro/installer.sh -O - | /bin/sh",
    "The Weather": "wget https://raw.githubusercontent.com/biko-73/TheWeather/main/installer.sh -O - | /bin/sh",
    "Youtube": "wget https://dreambox4u.com/emilnabil237/plugins/YouTube/installer.sh -qO - | /bin/sh",
    "BouquetMakerXtream": "wget http://dreambox4u.com/emilnabil237/plugins/BouquetMakerXtream/installer.sh -qO - | /bin/sh",
    "QuarterPounder": "wget http://dreambox4u.com/emilnabil237/script/quarterpounder.sh -qO - | /bin/sh",
    "XcPlugin Forever": "wget https://raw.githubusercontent.com/Belfagor2005/xc_plugin_forever/main/installer.sh -qO - | /bin/sh",
    "Xklass Iptv": "wget https://dreambox4u.com/emilnabil237/plugins/xklass/installer.sh -O - | /bin/sh",
    "X-Streamity": "wget https://raw.githubusercontent.com/biko-73/xstreamity/main/installer.sh -qO - | /bin/sh",
    "JediMakerXtream": "wget https://raw.githubusercontent.com/biko-73/JediMakerXtream/main/installer.sh -qO - | /bin/sh",
    "HasBahCa": "wget https://dreambox4u.com/emilnabil237/plugins/HasBahCa/installer.sh -qO - | /bin/sh",
    "KeyAdder": "wget -q --no-check-certificate https://raw.githubusercontent.com/fairbird/KeyAdder/main/installer.sh -O - |/bin/sh",
    "feeds-finder": "wget -q --no-check-certificate https://dreambox4u.com/emilnabil237/plugins/feeds-finder/installer.sh -O - | /bin/sh",
    "MyCam-Plugin": "wget https://dreambox4u.com/emilnabil237/plugins/mycam/installer.sh -O - | /bin/sh",
    "RaedQuickSignal": "wget https://raw.githubusercontent.com/fairbird/RaedQuickSignal/main/installer.sh -O - | /bin/sh",
    "VertualKeyboard": "wget https://raw.githubusercontent.com/emil237/NewVirtualKeyBoard/main/installer.sh -O - | /bin/sh",
    "SubsSupport_2.1": "wget https://dreambox4u.com/emilnabil237/plugins/SubsSupport/subssupport_2.1.sh -O - | /bin/sh",
  "XtraEvante_v4.6": "wget https://github.com/emil237/download-plugins/raw/main/Xtraevent-v4.6.sh -qO - | /bin/sh",
    "XtraEvante_v5.2": "wget https://github.com/digiteng/xtra/raw/main/xtraEvent.sh -qO - | /bin/sh",
  "XtraEvante_v5.3": "wget https://raw.githubusercontent.com/emil237/download-plugins/main/xtraEvent_5.3.sh -qO - | /bin/sh",
  "xtraevent_v6.798": "wget https://dreambox4u.com/emilnabil237/plugins/xtraevent/xtraevent_6.798.sh -qO - | /bin/sh", 

  "############ ( TOOLS ) ############": "", 
    "Wget": "opkg install wget",
  "Curl": "opkg install curl",
  "UPDATE ENIGMA2 ALL PYTHON": "wget https://raw.githubusercontent.com/emil237/updates-enigma/main/update-all-python.sh -O - | /bin/sh",
 "servicescanupdates_1.2": "wget https://dreambox4u.com/emilnabil237/plugins/servicescanupdates/servicescanupdates.sh -O - | /bin/sh",
   "Super Script": "wget https://dreambox4u.com/emilnabil237/script/Super_Script.sh -O - | /bin/sh",
  "OpenATV softcamfeed": "wget -O - -q http://updates.mynonpublic.com/oea/feed | bash",
 "Fix Softcam OpenPli": "wget https://raw.githubusercontent.com/emil237/download-plugins/main/softcam-support-pli.sh -O - | /bin/sh",
    "Update OpenATV Develop feed": "wget -O - -q https://feeds2.mynonpublic.com/devel-feed | bash",
     "Repair-Inodes-From-Hdd": "wget https://raw.githubusercontent.com/emil237/scripts/refs/heads/main/repair-hdd.sh -O - | /bin/sh", "FIX-ipk-Package-Installation": "wget https://dreambox4u.com/emilnabil237/script/fix-ipk-package-installation.sh -O - | /bin/sh",
  "update": "opkg update",
    "astra-sm": "opkg install astra-sm",
    "gstplayer": "opkg install gstplayer",
    "Streamlinksrv": "opkg install streamlinksrv",
    "dabstreamer": "opkg install dabstreamer",
    "eti_tools": "opkg install eti-tools",
    "dvbsnoop": "opkg install dvbsnoop", 

"######"
   "############ ( SOFTCAMS ) ############": "", 
    "Cccam": "wget https://dreambox4u.com/emilnabil237/emu/installer-cccam.sh -O - | /bin/sh",
    "Oscam Mohamed_OS": "wget https://dreambox4u.com/emilnabil237/emu/installer-oscam.sh  -O - | /bin/sh",
    "Ncam fairman": "wget https://dreambox4u.com/emilnabil237/emu/installer-ncam.sh -O - | /bin/sh",
    "Oscam Emu biko-73": "wget https://raw.githubusercontent.com/biko-73/OsCam_EMU/main/installer.sh -O - | /bin/sh", 
 
    "############ ( SKINS ) ############": "", 
"BO-HLALA FHD SKIN": "wget https://raw.githubusercontent.com/biko-73/TeamNitro/main/script/installerB.sh -O - | /bin/sh",
    "Red-Dragon-FHD": "wget https://raw.githubusercontent.com/biko-73/TeamNitro/main/script/installerD.sh -O - | /bin/sh",
    "Nitro AdvanceFHD": "wget https://raw.githubusercontent.com/biko-73/NitroAdvanceFHD/main/installer.sh -qO - | /bin/sh",
    "Desert skin": "wget https://raw.githubusercontent.com/biko-73/TeamNitro/main/script/installerDs.sh -O - | /bin/sh", 

  "############ ( Free ) ############": "", 
    "FreeServerCCcam": "wget https://ia803104.us.archive.org/0/items/freecccamserver/installer.sh -qO - | /bin/sh", 
 
"############ ( BootlogoSwapper ) ############": "", 
"BootlogoSwapper Atv": "wget http://dreambox4u.com/emilnabil237/script/bootlogoswapper-Atv.sh -O - | /bin/sh",
"BootlogoSwapper-christmas": "wget http://dreambox4u.com/emilnabil237/script/bootlogoswapper-christmas.sh -O - | /bin/sh",
"BootlogoSwapper-OpenPli": "wget http://dreambox4u.com/emilnabil237/script/bootlogoswapper-pli.sh -O - | /bin/sh",
"bootlogoSwapper-OpenBH": "wget http://dreambox4u.com/emilnabil237/script/bootlogoswapper-OpenBH.sh  -O - | /bin/sh",
"BootlogoSwapper_Egami": "wget http://dreambox4u.com/emilnabil237/script/bootLogoswapper-Egami.sh -O - | /bin/sh",
"BootlogoSwapper_OpenVix": "wget http://dreambox4u.com/emilnabil237/script/bootlogoswapper-OpenVix.sh -O - | /bin/sh",
"BootlogoSwapper_PURE2": "wget http://dreambox4u.com/emilnabil237/script/bootLogoswapper-Pure2.sh -O - | /bin/sh",
"BootlogoSwapper_Kids": "wget http://dreambox4u.com/emilnabil237/script/bootlogoswapper-kids.sh -O - | /bin/sh",
"BootlogoSwapper_Ramadan": "wget http://dreambox4u.com/emilnabil237/script/bootlogo-swapper-ramadan.sh -O - | /bin/sh", 

}

class CiefpsettingsPanel(Screen):
    skin = f"""
    <screen name="CiefpsettingsPanel" position="center,center" size="800,500" title="CiefpsettingsPanel" backgroundColor="#000000">
        <ePixmap pixmap="{ICON_PIXMAP}" position="10,10" size="100,40" alphatest="on" />
        <widget name="menu" position="10,50" size="780,350" scrollbarMode="showOnDemand" font="Regular;22" backgroundColor="#19184D" foregroundColor="#FFFFFF" foregroundColorSelected="#FF8C00" />
        <widget name="status" position="10,420" size="780,30" font="Regular;20" halign="center" foregroundColor="#FFFFFF" backgroundColor="#000080" />
        <widget name="key_red" position="10,460" size="180,30" font="Regular;18" halign="center" backgroundColor="#9F1313" />
        <widget name="key_green" position="310,460" size="180,30" font="Regular;18" halign="center" backgroundColor="#1F771F" />
        <widget name="key_blue" position="610,460" size="180,30" font="Regular;18" halign="center" backgroundColor="#13389F" />
    </screen>
    """

    def __init__(self, session):
        self.session = session
        Screen.__init__(self, session)

        self["menu"] = MenuList(list(PLUGINS_LIST.keys()))
        self["status"] = Label("Choose a plugin to install")
        self["key_red"] = Button("Exit")
        self["key_green"] = Button("Install")
        self["key_blue"] = Button("Restart E2")

        self["actions"] = ActionMap(
            ["ColorActions", "SetupActions"],
            {
                "red": self.close,
                "green": self.install_plugin,
                "ok": self.install_plugin,
                "blue": self.restart_enigma2,
                "cancel": self.close,
            },
        )

        self.container = eConsoleAppContainer()
        self.container.appClosed.append(self.command_finished)

        self.update_plugin()

    def update_plugin(self):
        try:
     
            urllib.request.urlretrieve(PLUGIN_FILE_URL, "/tmp/plugin.py")
            
            if not self.files_are_identical("/tmp/plugin.py", LOCAL_PLUGIN_FILE_PATH):
  
                os.rename("/tmp/plugin.py", LOCAL_PLUGIN_FILE_PATH)
                self["status"].setText("Plugin updated successfully!")
            else:
                self["status"].setText("Plugin is up to date.")
        except Exception as e:
            self["status"].setText(f"Failed to update plugin: {e}")

    def files_are_identical(self, file1, file2):
       
        try:
            with open(file1, "rb") as f1, open(file2, "rb") as f2:
                return f1.read() == f2.read()
        except FileNotFoundError:
            return False

    def install_plugin(self):
        selected = self["menu"].getCurrent()
        if selected:
            command = PLUGINS_LIST[selected]
            self["status"].setText(f"Installing: {selected}")
            self.container.execute(command)

    def command_finished(self, retval):
        if retval == 0:
            self["status"].setText("Installation completed successfully!")
        else:
            self["status"].setText("Installation failed!")

    def restart_enigma2(self):
        self.container.execute("init 4 && init 3")
        self.close()

def Plugins(**kwargs):
    return [
        PluginDescriptor(
            name=PLUGIN_NAME,
            description=f"Manage plugins with {PLUGIN_NAME} (v{PLUGIN_VERSION})",
            where=PluginDescriptor.WHERE_PLUGINMENU,
            icon=ICON_PATH,
            fnc=lambda session, **kwargs: session.open(CiefpsettingsPanel),
        )
    ]



