import socket
import os
import sys
from Plugins.Plugin import PluginDescriptor
from Screens.Screen import Screen
from Components.ActionMap import ActionMap
from Components.Label import Label
from Components.MenuList import MenuList
from Components.Button import Button
from Components.Sources.List import List
from Components.ProgressBar import ProgressBar
from Components.config import config, ConfigSubsection
from enigma import eConsoleAppContainer, eTimer, ePixmap, eListboxPythonMultiContent, gFont, RT_HALIGN_LEFT, RT_VALIGN_CENTER
from Tools.Directories import resolveFilename, SCOPE_PLUGINS
from Tools.LoadPixmap import LoadPixmap
from Screens.MessageBox import MessageBox
from Screens.Standby import TryQuitMainloop

config.plugins.smartaddons = ConfigSubsection()

PLUGIN_ICON = "icon.png"
PLUGIN_VERSION = "4.0.9"
VERSION_URL = "https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/SmartAddonspanel/Py3/version.txt"
UPDATE_SCRIPT_URL = "https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/SmartAddonspanel/smart-Panel.sh"

class InstallProgressScreen(Screen):
    skin = """
    <screen name="InstallProgressScreen" position="center,center" size="700,200" title="Installing...">
        <widget name="progress" position="10,30" size="680,20" backgroundColor="#404040" />
        <widget name="status" position="10,60" size="680,100" font="Regular;22" transparent="1" />
        <widget name="percentage" position="10,150" size="680,20" font="Regular;24" halign="right" />
        <widget name="key_red" position="250,160" size="200,30" font="Bold;24" halign="center" backgroundColor="#C80000" foregroundColor="#FFFFFF" />
    </screen>
    """

    def __init__(self, session, selected_plugins, callback):
        Screen.__init__(self, session)
        self.selected_plugins = selected_plugins
        self.callback = callback
        self.container = eConsoleAppContainer()
        self.container.appClosed.append(self.command_finished)
        self.container.dataAvail.append(self.command_output)
        self.current_plugin_index = 0
        self.total_plugins = len(selected_plugins)
        self["progress"] = ProgressBar()
        self["status"] = Label("")
        self["percentage"] = Label("")
        self["key_red"] = Button("Cancel")
        self["actions"] = ActionMap(["ColorActions"], {"red": self.on_cancel}, -1)
        self.run_next_command()

    def run_next_command(self):
        if self.current_plugin_index < self.total_plugins:
            progress = int(((self.current_plugin_index + 1) / self.total_plugins) * 100)
            self["progress"].setValue(progress)
            self["percentage"].setText(f"{progress}%")
            name, cmd = self.selected_plugins[self.current_plugin_index]
            self["status"].setText(f"Installing: {name} ({self.current_plugin_index + 1}/{self.total_plugins})")
            self.container.execute(cmd)
        else:
            self.session.openWithCallback(self.restart_enigma2, MessageBox,
                f"Successfully installed {self.total_plugins} plugins. Restart Enigma2 now?", MessageBox.TYPE_YESNO)

    def command_output(self, data):
        pass

    def command_finished(self, retval):
        if retval != 0:
            self.session.openWithCallback(self.on_error, MessageBox,
                f"Installation failed with error code {retval}. Continue?", MessageBox.TYPE_YESNO)
        else:
            self.current_plugin_index += 1
            self.run_next_command()

    def on_error(self, answer):
        if answer:
            self.current_plugin_index += 1
            self.run_next_command()
        else:
            self.close()

    def on_cancel(self):
        if self.container.running:
            self.container.kill()
        self.session.open(MessageBox, "Installation cancelled.", MessageBox.TYPE_INFO)
        self.close()

    def restart_enigma2(self, answer):
        if answer:
            self.session.open(TryQuitMainloop, 3)
        self.close()

    def close(self):
        if hasattr(self, "container") and self.container.running:
            self.container.kill()
        if self.callback:
            self.callback()
        super().close()

class SmartAddonspanel(Screen):
    skin = """
    <screen name="SmartAddonspanel" position="left,center" size="1920,1080" title="Smart Addons Panel By Emil Nabil">
        <ePixmap position="0,0" size="1920,1080" pixmap="/usr/lib/enigma2/python/Plugins/Extensions/SmartAddonspanel/icons/background.png" zPosition="-1" />
        <widget name="main_menu" position="30,60" size="500,900" scrollbarMode="showOnDemand" itemHeight="70" backgroundColor="#000000"
foregroundColor="#FFD700" font="Bold;40" flags="RT_HALIGN_LEFT" />
        <widget source="sub_menu" render="Listbox" position="560,50" size="650,900" scrollbarMode="showOnDemand"
backgroundColor="#000000"
transparent="0">
            <convert type="TemplatedMultiContent">
                {"template": [
                    MultiContentEntryPixmapAlphaBlend(pos=(5,10), size=(50,50), png=2),
                    MultiContentEntryText(pos=(60,0), size=(580,35), font=0, flags=RT_HALIGN_LEFT|RT_VALIGN_CENTER, text=0),
                    MultiContentEntryText(pos=(60,35), size=(580,35), font=0, flags=RT_HALIGN_LEFT|RT_VALIGN_CENTER, text=1),
                ],
                "fonts": [gFont("Regular",24)],
                "itemHeight": 90
                }
            </convert>
        </widget>
        <widget name="status" position="30,965" size="1080,40" font="Regular;30" halign="center" backgroundColor="#303030" />
        <widget name="key_green" position="30,1010" size="376,55" font="Bold;28" halign="center" backgroundColor="#1F771F" />
        <widget name="key_yellow" position="427,1010" size="376,55" font="Bold;28" halign="center" backgroundColor="#FFC000" />
        <widget name="key_blue" position="824,1010" size="376,55" font="Bold;28" halign="center" backgroundColor="#13389F" />
        <widget name="python_version" position="1300,960" size="600,50" font="Regular;35" halign="center" backgroundColor="#423C3D" foregroundColor="#FFFFFF" />
        <widget source="session.VideoPicture" render="Pig" position="1280,60" size="600,350" zPosition="1" backgroundColor="#ff000000" />
        <widget name="receiver_model" position="1300,420" size="600,50" font="Regular;35" halign="center" backgroundColor="#423C3D" foregroundColor="#FFFFFF" />
        <widget name="image_type" position="1300,480" size="600,50" font="Regular;35" halign="center" backgroundColor="#423C3D" foregroundColor="#FFFFFF" />
        <widget name="image_version" position="1300,540" size="600,50" font="Regular;35" halign="center" backgroundColor="#423C3D" foregroundColor="#FFFFFF" />
        <widget name="cpu_info" position="1300,600" size="600,50" font="Regular;35" halign="center" backgroundColor="#423C3D" foregroundColor="#FFFFFF" />
        <widget name="memory_info" position="1300,660" size="600,50" font="Regular;35" halign="center" backgroundColor="#423C3D" foregroundColor="#FFFFFF" />
        <widget name="storage_info" position="1300,720" size="600,50" font="Regular;35" halign="center" backgroundColor="#423C3D" foregroundColor="#FFFFFF" />
        <widget name="mount_info" position="1300,780" size="600,50" font="Regular;35" halign="center" backgroundColor="#423C3D" foregroundColor="#FFFFFF" />
        <widget name="ip_address" position="1300,840" size="600,55" font="Regular;35" halign="center" backgroundColor="#423C3D" foregroundColor="#FFFFFF" />
        <widget name="internet_status" position="1300,900" size="600,50" font="Regular;35" halign="center" backgroundColor="#423C3D" foregroundColor="#FFFFFF" />
    </screen>
    """

    def __init__(self, session):
        Screen.__init__(self, session)
        self.session = session
        self.main_menu = ["Panels", "Plugins", "System Plugins", "DNS Resolver Network", "Media", "Tools", "Images", "Picons", "Emu", "Channels-other", "Channels_Siefp_E2", 
  "Channels-Vanenbal",
  "Channels-morpheus883",
  "Key Plugins", "Multiboot Plugins", "Bootlogo", "Display-Skin", "Backup-Settengs-Menu", "Restore-Settengs-Menu", "Skins Other", "Skins TeamNitro", "Skins Atv", "Skins Egami", "Skins Open BlackHole", "Skins OpenPli Py3", "Skins OpenVix", "Skins OpenSpa", "Skins OpenPli Py2", "Skins BlackHole", "Skins Vti", "Themes"]
        self.sub_menus = {
            "Panels": [
                ("Ajpanel", "wget http://dreambox4u.com/emilnabil237/plugins/ajpanel/installer1.sh -O - | /bin/sh"),
        ("AjPanel Custom Menu All Panels", "wget https://dreambox4u.com/emilnabil237/plugins/ajpanel/emil-panel-all.sh -O - | /bin/sh"),
        ("Panel Lite By Emil Nabil", "wget https://dreambox4u.com/emilnabil237/plugins/ajpanel/new/emil-panel-lite.sh -O - | /bin/sh"),
        ("Emil Panel", "wget https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilPanel/emilpanel.sh -O - | /bin/sh"),
("Ciefp-Panel", "wget https://github.com/ciefp/CiefpsettingsPanel/raw/main/installer.sh -O - | /bin/sh"),
("Ciefp-Panel mod Emil Nabil", "wget https://github.com/emilnabil/download-plugins/raw/refs/heads/main/Ciefp-Panel/Ciefp-Panel.sh -O - | /bin/sh"),
        ("dreamosat-downloader", "wget https://dreambox4u.com/emilnabil237/plugins/dreamosat-downloader/installer.sh -O - | /bin/sh"),
        ("EliesatPanel", "wget https://raw.githubusercontent.com/eliesat/eliesatpanel/main/installer.sh -O - | /bin/sh"),
        ("Epanel", "wget https://dreambox4u.com/emilnabil237/plugins/epanel/installer.sh -O - | /bin/sh"),
        ("linuxsat-panel", "wget https://raw.githubusercontent.com/Belfagor2005/LinuxsatPanel/main/installer.sh -O - | /bin/sh"),
        ("levi45-AddonsManager", "wget https://dreambox4u.com/emilnabil237/plugins/levi45-addonsmanager/installer.sh -O - | /bin/sh"),
        ("Levi45MulticamManager", "wget https://dreambox4u.com/emilnabil237/plugins/levi45multicammanager/installer.sh -O - | /bin/sh"),
        ("MagicPanel-HAMDY_AHMED", "wget https://gitlab.com/h-ahmed/Panel/-/raw/main/MagicPanel_install.sh -O - | /bin/sh"),
        ("SatVenusPanel", "wget https://dreambox4u.com/emilnabil237/plugins/satvenuspanel/installer.sh -O - | /bin/sh"),
        ("Tspanel", "wget https://dreambox4u.com/emilnabil237/plugins/tspanel/installer.sh -O - | /bin/sh"),
        ("TvAddon-Panel", "wget https://dreambox4u.com/emilnabil237/plugins/tvaddon/installer.sh -O - | /bin/sh"),
    ],
            "Plugins": [
                ("ArabicSavior", "wget http://dreambox4u.com/emilnabil237/plugins/ArabicSavior/installer.sh -O - | /bin/sh"),
          ("Acherone", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/acherone/installer.sh -O - | /bin/sh"),   
            ("Alajre", "wget https://dreambox4u.com/emilnabil237/plugins/alajre/installer.sh -O - | /bin/sh"),
       ("Ansite", "wget https://raw.githubusercontent.com/emil237/ansite/refs/heads/main/installer.sh -O - | /bin/sh"),
       ("Apod", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/apod/installer.sh -O - | /bin/sh"), 
         ("Astronomy", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/astronomy/installer.sh -O - | /bin/sh"),    
       ("Athan Times", "wget https://dreambox4u.com/emilnabil237/plugins/athantimes/installer.sh -O - | /bin/sh"), 
        ("Atilehd", "wget https://dreambox4u.com/emilnabil237/plugins/atilehd/installer.sh -O - | /bin/sh"),
         ("automatic-fullbackup", "wget https://dreambox4u.com/emilnabil237/plugins/automatic-fullbackup/installer.sh -O - | /bin/sh"), 
         ("Azkar Almuslim", "wget https://dreambox4u.com/emilnabil237/plugins/azkar-almuslim/installer.sh -O - | /bin/sh"), 
        ("Bitrate", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/bitrate/bitrate.sh -O - | /bin/sh"),
        ("Bitrate-mod-ariad", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/bitrate/bitrate-mod-ariad.sh -O - | /bin/sh"),  
        ("Bundesliga-Permanent-Clock", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/bundesliga-permanent-clock/bundesliga-permanent-clock.sh -O - | /bin/sh"),
       ("CacheFlush", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/cacheflush/cacheflush.sh -O - | /bin/sh"), 
       ("CCcaminfo-py2", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/cccaminfo/cccaminfo_py2.sh -O - | /bin/sh"),
       ("CCcaminfo-py3", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/cccaminfo/cccaminfo_py3.sh -O - | /bin/sh"),
      ("CrondManager", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/crondmanager/installer.sh -O - | /bin/sh"), 
       ("CFG_ZOOM_FINAL", "wget https://dreambox4u.com/emilnabil237/plugins/cfg_Zoom_Final_FIX7x/installer.sh -O - | /bin/sh"), 
        ("CiefpBouquetUpdater", "wget https://raw.githubusercontent.com/ciefp/CiefpBouquetUpdater/main/installer.sh -O - | /bin/sh"),
        ("CiefpIPTVBouquets", "wget https://raw.githubusercontent.com/ciefp/CiefpIPTVBouquets/main/installer.sh -O - | /bin/sh"), ("CiefpSatelliteXmlEditor", "wget https://raw.githubusercontent.com/ciefp/CiefpSatelliteXmlEditor/main/installer.sh -O - | /bin/sh"),
("CiefpSettingsDownloader", "wget https://raw.githubusercontent.com/ciefp/CiefpSettingsDownloader/main/installer.sh -O - | /bin/sh"),
    ("CiefpsettingsMotor", "wget https://raw.githubusercontent.com/ciefp/CiefpsettingsMotor/main/installer.sh -O - | /bin/sh"), 
    ("CiefpSelectSatellite", "wget https://raw.githubusercontent.com/ciefp/CiefpSelectSatellite/main/installer.sh -O - | /bin/sh"), 
    ("CiefpE2Converter", "wget https://raw.githubusercontent.com/ciefp/CiefpE2Converter/main/installer.sh -O - | /bin/sh"),
    ("Ciefp-Plugins", "wget https://raw.githubusercontent.com/ciefp/CiefpPlugins/main/installer.sh -O - | /bin/sh"),
 ("CiefpWhitelistStreamrelay", "wget https://raw.githubusercontent.com/ciefp/CiefpWhitelistStreamrelay/main/installer.sh -O - | /bin/sh"),
("CiefpSettingsStreamrela_PY3", "wget https://raw.githubusercontent.com/ciefp/CiefpSettingsStreamrelay/main/installer.sh -O - | /bin/sh"),
("CiefpSettingsStreamrela_PY2", "wget https://raw.githubusercontent.com/ciefp/CiefpSettingsStreamrelayPY2/main/installer.sh -O - | /bin/sh"),
("CiefpSettingsT2miAbertis", "wget https://raw.githubusercontent.com/ciefp/CiefpSettingsT2miAbertis/main/installer.sh -O - | /bin/sh"),
("CiefpSettingsT2miAbertisOpenPLi", "wget https://raw.githubusercontent.com/ciefp/CiefpSettingsT2miAbertisOpenPLi/main/installer.sh -O - | /bin/sh"),
("chocholousek-picons", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/chocholousek-picons.sh -O - | /bin/sh"),
 ("CHLogoChanger", "wget https://dreambox4u.com/emilnabil237/plugins/CHLogoChanger/ChLogoChanger.sh -O - | /bin/sh"),
                ("CrashLogoViewer", "wget https://dreambox4u.com/emilnabil237/plugins/crashlogviewer/install-CrashLogViewer.sh -O - | /bin/sh"),
       ("CrondManger", "wget https://github.com/emil237/download-plugins/raw/main/cronmanager.sh -O - | /bin/sh"),
       ("enigma2readeradder", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/enigma2readeradder.sh -O - | /bin/sh"), 
       ("Epg Grabber", "wget https://dreambox4u.com/emilnabil237/plugins/Epg-Grabber/installer.sh -O - | /bin/sh"), 
       ("EPGImport", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/epgimport.sh -O - | /bin/sh"), 
       ("EPGImport-99", "wget https://raw.githubusercontent.com/Belfagor2005/EPGImport-99/main/installer.sh -O - | /bin/sh"), 
       ("EPGTranslator", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/epgtranslator.sh -O - | /bin/sh"),
      ("Filmxy", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/filmxy/filmxy.sh -O - | /bin/sh"), 
        ("Footonsat", "wget https://dreambox4u.com/emilnabil237/plugins/FootOnsat/installer.sh -O - | /bin/sh"),
       ("Freearhey", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/freearhey/freearhey.sh -O - | /bin/sh"), 
 ("FreeCCcamServer", "wget https://ia803104.us.archive.org/0/items/freecccamserver/installer.sh -O - | /bin/sh"), 
("gioppygio", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/gioppygio/gioppygio.sh -O - | /bin/sh"),
       ("hardwareinfo", "wget https://dreambox4u.com/emilnabil237/plugins/hardwareinfo/installer.sh -O - | /bin/sh"),  
         ("HasBahCa", "wget https://dreambox4u.com/emilnabil237/plugins/HasBahCa/installer.sh -O - | /bin/sh"), 
         ("HistoryZapSelector", "wget https://dreambox4u.com/emilnabil237/plugins/historyzap/installer1.sh -O - | /bin/sh"),
         ("horoscope", "wget https://raw.githubusercontent.com/emilnabil/horoscope/refs/heads/main/horoscope.sh -O - | /bin/sh"), 
       ("HolidayCountdown", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/HolidayCountdown/installer.sh -O - | /bin/sh"),  
      ("Internet-Speedtest", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/internet-speedtest.sh -O - | /bin/sh"),
("Iptv-Org-Playlists", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/iptv-org-playlists/iptv-org-playlists.sh -O - | /bin/sh"),
      ("iptvdream", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/main/iptvdream/iptvdream.sh -O - | /bin/sh"),
         ("MoviesManager", "wget http://dreambox4u.com/emilnabil237/plugins/Transmission/MoviesManager.sh -O - | /bin/sh"),
    ("MyCam-Plugin", "wget https://dreambox4u.com/emilnabil237/plugins/mycam/installer.sh -O - | /bin/sh"),
     ("MultiCamAdder", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/MultiCamAdder/installer.sh -O - | /bin/sh"),
     ("Multi-Iptv-Adder", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/MultiIptvAdder/installer.sh -O - | /bin/sh"),
    ("NewVirtualkeyBoard", "wget https://dreambox4u.com/emilnabil237/plugins/NewVirtualKeyBoard/installer.sh -O - | /bin/sh"),
 ("ONEupdater", "wget https://raw.githubusercontent.com/Sat-Club/ONEupdaterE2/main/installer.sh -O - | /bin/sh"),
    ("Ozeta-Skins-Setup", "wget https://raw.githubusercontent.com/emil237/skins-enigma2/main/PLUGIN_Skin-ozeta.sh -O - | /bin/sh"), 
    ("Plutotv", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/main/plutotv/plutotv.sh -O - | /bin/sh"),
("Quran-karem", "wget https://dreambox4u.com/emilnabil237/plugins/quran/installer.sh -O - | /bin/sh"),
("Quran-karem_v2.2", "wget https://raw.githubusercontent.com/emil237/quran/main/installer.sh -O - | /bin/sh"),
("Radio-80-s", "wget https://raw.githubusercontent.com/Belfagor2005/Radio-80-s/main/installer.sh -O - | /bin/sh"),  
     ("Radiom", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/main/radiom/radiom.sh -O - | /bin/sh"),
     ("Rakutentv", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/main/rakutentv/rakutentv.sh -O - | /bin/sh"),
      ("RaedQuickSignal", "wget https://dreambox4u.com/emilnabil237/plugins/RaedQuickSignal/installer.sh -O - | /bin/sh"),
       ("pluginmover", "wget http://dreambox4u.com/emilnabil237/plugins/pluginmover/installer.sh -O - | /bin/sh"),
       ("pluginskinmover", "wget http://dreambox4u.com/emilnabil237/plugins/pluginskinmover/installer.sh -O - | /bin/sh"), 
       ("ScreenNames", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/screennames/screennames.sh -O - | /bin/sh"),
       ("Screen-Recorder", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/screenrecorder/installer.sh -O - | /bin/sh"),
       ("SetPicon", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/setpicon/installer.sh -O - | /bin/sh"),
        ("scriptexecuter", "wget http://dreambox4u.com/emilnabil237/plugins/scriptexecuter/installer.sh -O - | /bin/sh"),
        ("showclock", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/showclock/showclock.sh -O - | /bin/sh"),
     ("Sherlockmod", "wget https://raw.githubusercontent.com/emil237/sherlockmod/main/installer.sh -O - | /bin/sh"), 
         ("Simple-Zoom-Panel", "wget https://dreambox4u.com/emilnabil237/plugins/simple-zoom-panel/installer.sh -O - | /bin/sh"), 
         ("SubsSupport_1.5.8-r9", "wget https://dreambox4u.com/emilnabil237/plugins/SubsSupport/installer1.sh -O - | /bin/sh"), 
         ("SubsSupport_by-m.nasr", "wget https://github.com/popking159/ssupport/raw/main/subssupport-install.sh -O - | /bin/sh"), 
         ("SubsSupport_2.1", "wget https://dreambox4u.com/emilnabil237/plugins/SubsSupport/subssupport_2.1.sh -O - | /bin/sh"),
    ("uninstaller-Plugins", "wget http://dreambox4u.com/emilnabil237/plugins/unstaller-plugins/installer.sh -O - | /bin/sh"), 
    ("vavoo_1.15", "wget https://dreambox4u.com/emilnabil237/plugins/vavoo/installer.sh -O - | /bin/sh"), 
    ("xtraevent_3.3", "wget https://raw.githubusercontent.com/emil237/download-plugins/main/xtraevent_3.3.sh -O - | /bin/sh"), 
 ("xtraevent_4.2", "wget https://raw.githubusercontent.com/emil237/download-plugins/main/xtraEvent_4.2.sh -O - | /bin/sh"),
                ("xtraevent_4.5", "wget https://raw.githubusercontent.com/emil237/download-plugins/main/xtraEvent_4.5.sh -O - | /bin/sh"),
       ("Xtraevent_4.6", "wget https://github.com/emil237/download-plugins/raw/main/Xtraevent-v4.6.sh -O - | /bin/sh"),
       ("xtraevent_6.798", "wget https://dreambox4u.com/emilnabil237/plugins/xtraevent/xtraevent_6.798.sh -O - | /bin/sh"), 
       ("xtraevent_6.805", "wget https://dreambox4u.com/emilnabil237/plugins/xtraevent/xtraevent-6.805.sh -O - | /bin/sh"),
        ("xtraevent_6.820_All-Python", "wget https://dreambox4u.com/emilnabil237/plugins/xtraevent/xtraevent-6.820.sh -O - | /bin/sh"),
     ("WorldCam", "wget https://raw.githubusercontent.com/Belfagor2005/WorldCam/main/installer.sh -O - | /bin/sh"),   
     ("Zip2Pkg-Converter", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/Zip2Pkg/installer.sh -O - | /bin/sh"), 
        ("Zoom_1.1.2-Py3", "wget https://dreambox4u.com/emilnabil237/plugins/zoom/installer.sh -O - | /bin/sh"),
            ],
    "System Plugins": [
                ("3gmodemmanager", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/3gmodemmanager.sh -O - | /bin/sh"),
 ("devicemanager", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/devicemanager.sh -O - | /bin/sh"),
 ("mountmanager", "wget https://dreambox4u.com/emilnabil237/plugins/muntmanger/installer.sh -O - | /bin/sh"),
 ("servicescanupdates", "wget https://dreambox4u.com/emilnabil237/plugins/servicescanupdates/servicescanupdates.sh -O - | /bin/sh"),
 ("setpasswd", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/setpasswd.sh -O - | /bin/sh"),
 ("Signalfinder", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/signalfinder.sh -O - | /bin/sh"),
 ("softwaremanager", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/softwaremanager.sh -O - | /bin/sh"),
 ("Ts-Sateditor", "wget https://dreambox4u.com/emilnabil237/plugins/ts-sateditor/ts-sateditor.sh -O - | /bin/sh"),
 ("Xmlupdate", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/xmlupdate.sh -O - | /bin/sh"),
            ],
          "DNS Resolver Network": [
    ("Google DNS", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/dns/dns-google.sh -O - | /bin/sh"),
    ("Cloudflare DNS", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/dns/dns-cloudflare.sh -O - | /bin/sh"),
    ("CleanBrowsing DNS", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/dns/dns-cleanbrowsing.sh -O - | /bin/sh"),
    ("Quad9 DNS", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/dns/dns-quad9.sh -O - | /bin/sh"),
    ("Open-Home DNS", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/dns/dns-openhome.sh -O - | /bin/sh"),
    ("Comodo DNS", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/dns/dns-comodo.sh -O - | /bin/sh"),
    ("Alternate DNS", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/dns/dns-alternate.sh -O - | /bin/sh"),
    ("AdGuard DNS", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/dns/dns-adguard.sh -O - | /bin/sh"),
    ("Control DNS", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/dns/dns-control.sh -O - | /bin/sh"),
],
    "Media": [
        ("BouquetMakerXtream", "wget http://dreambox4u.com/emilnabil237/plugins/BouquetMakerXtream/installer.sh -O - | /bin/sh"),
        ("E2m3u2Bouquet", "wget https://dreambox4u.com/emilnabil237/plugins/e2m3u2bouquet/installer.sh -O - | /bin/sh"),
  ("E2Player-MAXBAMBY", "wget https://gitlab.com/maxbambi/e2iplayer/-/raw/master/install-e2iplayer.sh  -O - | /bin/sh"),
  ("E2Player-ZADMARIO", "wget https://gitlab.com/zadmario/e2iplayer/-/raw/master/install-e2iplayer.sh  -O - | /bin/sh"),
        ("IptoSat", "wget https://dreambox4u.com/emilnabil237/plugins/iptosat/installer.sh  -O - | /bin/sh"),
        ("IpAudio_6.7_py2", "wget https://dreambox4u.com/emilnabil237/plugins/ipaudio/installer.sh -O - | /bin/sh"),
        ("IpAudio_7.4_py3", "wget https://dreambox4u.com/emilnabil237/plugins/ipaudio/ipaudio-7.4-ffmpeg.sh -O - | /bin/sh"),
        ("IpAudioPro", "wget https://dreambox4u.com/emilnabil237/plugins/ipaudiopro/installer.sh  -O - | /bin/sh"),
        ("JediEpgExtream", "wget https://dreambox4u.com/emilnabil237/plugins/jediepgextream/installer.sh -O - | /bin/sh"),
        ("jedimakerxtream", "wget https://dreambox4u.com/emilnabil237/plugins/jedimakerxtream/installer.sh -O - | /bin/sh"),
        ("multistalker", "wget https://dreambox4u.com/emilnabil237/plugins/multistalker/installer.sh -O - | /bin/sh"),
        ("MultiStalkerPro", "wget https://raw.githubusercontent.com/emilnabil/multi-stalkerpro/main/installer.sh -O - | /bin/sh"),
        ("Quarter pounder", "wget http://dreambox4u.com/emilnabil237/script/quarterpounder.sh -O - | /bin/sh"),
        ("Suptv", "wget https://raw.githubusercontent.com/emil237/suptv/main/installer.sh -O - | /bin/sh"),
        ("YouTube", "wget https://dreambox4u.com/emilnabil237/plugins/YouTube/installer.sh -O - | /bin/sh"),
        ("xklass-iptv", "wget https://dreambox4u.com/emilnabil237/plugins/xklass/installer.sh -O - | /bin/sh"),
        ("Xtreamty", "wget https://dreambox4u.com/emilnabil237/plugins/xtreamity/installer.sh -O - | /bin/sh"),
        ("Xcpluginforever", "wget https://raw.githubusercontent.com/Belfagor2005/xc_plugin_forever/main/installer.sh -O - | /bin/sh"),
    ],
    "Tools": [   
("Wget", "opkg install wget"),
("Curl", "opkg install curl"),
("Update Enigma2 All Python", "wget https://raw.githubusercontent.com/emil237/updates-enigma/main/update-all-python.sh -O - | /bin/sh"),
("Opkg", "wget http://dreambox4u.com/emilnabil237/script/opkg.sh -qO - | /bin/sh"),
("Super Script", "wget https://dreambox4u.com/emilnabil237/script/Super_Script.sh -O - | /bin/sh"),
("Delete the password", "passwd -d root"),
("Change-Password-To-root", 'printf "root\nroot\n" | passwd')
,
("CAM-abertis-astra-sm", "wget https://dreambox4u.com/emilnabil237/script/CAM-abertis-astra.sh -O - | /bin/sh"),
        ("FORMAT_HDD_TO-Ext4", "wget https://raw.githubusercontent.com/emil237/scripts/refs/heads/main/format-hdd.sh -O - | /bin/sh"),
        ("Repair-Inodes-From-Hdd", "wget https://raw.githubusercontent.com/emil237/scripts/refs/heads/main/repair-hdd.sh -O - | /bin/sh"),
        ("FIX-ipk-package-installation", "wget https://dreambox4u.com/emilnabil237/script/fix-ipk-package-installation.sh -O - | /bin/sh"),
        ("Set_Time_NTP-Google", "wget https://dreambox4u.com/emilnabil237/script/set_time.sh -O - | /bin/sh"),
        ("Fix Softcam Atv", "wget http://updates.mynonpublic.com/oea/feed -O - | /bin/sh"),
        ("Fix Softcam OpenPli", "wget https://raw.githubusercontent.com/emil237/download-plugins/main/softcam-support-pli.sh -O - | /bin/sh"),
        ("Wget package Vti", "wget https://raw.githubusercontent.com/emil237/download-plugins/refs/heads/main/tool_vti-wget_1.16.3.sh  -O - | /bin/sh"),
        ("Feed OpenPicons", "wget https://dreambox4u.com/emilnabil237/script/openpicons-feed.sh -O - | /bin/sh"),
        ("Zip2ipk", "wget http://dreambox4u.com/emilnabil237/script/zip2ipk.sh -qO - | /bin/sh"),
    ],
    "Images": [
        ("BlackHole-3.1.0", "wget https://dreambox4u.com/emilnabil237/images/BlackHole-3.1.0.sh -O - | /bin/sh"),
        ("Egami-10.4", "wget https://dreambox4u.com/emilnabil237/images/egami-10.4.sh -O - | /bin/sh"),
        ("Openatv-6.4", "wget https://dreambox4u.com/emilnabil237/images/openatv-6.4.sh -O - | /bin/sh"),
        ("Openatv-7.0", "wget https://dreambox4u.com/emilnabil237/images/openatv-7.0.sh -O - | /bin/sh"),
        ("Openatv-7.1", "wget https://dreambox4u.com/emilnabil237/images/openatv-7.1.sh -O - | /bin/sh"),
        ("Openatv-7.2", "wget https://dreambox4u.com/emilnabil237/images/openatv-7.2.sh -O - | /bin/sh"),
        ("Openatv-7.3", "wget https://dreambox4u.com/emilnabil237/images/openatv-7.3.sh -O - | /bin/sh"),
        ("Openatv-7.4", "wget https://dreambox4u.com/emilnabil237/images/openatv-7.4.sh -O - | /bin/sh"),
        ("Openatv-7.5", "wget https://dreambox4u.com/emilnabil237/images/openatv-7.5.sh -O - | /bin/sh"),
        ("Openatv-7.5.1", "wget https://dreambox4u.com/emilnabil237/images/openatv-7.5.1.sh -O - | /bin/sh"),
        ("Openatv-7.6", "wget https://dreambox4u.com/emilnabil237/images/openatv-7.6.sh -O - | /bin/sh"),
        ("OpenBlackHole-4.4", "wget https://dreambox4u.com/emilnabil237/images/openblackhole-4.4-for-vuplus-only.sh -O - | /bin/sh"),
        ("OpenBlackHole-5.0", "wget https://dreambox4u.com/emilnabil237/images/openblackhole-5.0.sh -O - | /bin/sh"),
        ("OpenBlackHole-5.1", "wget https://dreambox4u.com/emilnabil237/images/openblackhole-5.1.sh -O - | /bin/sh"),
        ("OpenBlackHole-5.2", "wget https://dreambox4u.com/emilnabil237/images/openblackhole-5.2.sh -O - | /bin/sh"),
        ("OpenBlackHole-5.3", "wget https://dreambox4u.com/emilnabil237/images/openblackhole-5.3.sh -O - | /bin/sh"),
        ("OpenBlackHole-5.4", "wget https://dreambox4u.com/emilnabil237/images/openblackhole-5.4.sh -O - | /bin/sh"),
        ("OpenBlackHole-5.5.1", "wget https://dreambox4u.com/emilnabil237/images/openblackhole-5.5.1.sh -O - | /bin/sh"),
        ("OpenDroid", "wget https://dreambox4u.com/emilnabil237/images/opendroid.sh -O - | /bin/sh"),
        ("Openpli-7.3", "wget https://dreambox4u.com/emilnabil237/images/openpli-7.3.sh -O - | /bin/sh"),
        ("OpenPli-8.3", "wget https://dreambox4u.com/emilnabil237/images/openpli-8.3.sh -O - | /bin/sh"),
        ("OpenPli-8.3-Time-Shift", "wget https://dreambox4u.com/emilnabil237/images/openpli-8.3-py2-TimeShift.sh -O - | /bin/sh"),
        ("OpenPli-9.0-Time-Shift", "wget https://dreambox4u.com/emilnabil237/images/openpli-9.0-py3-TimeShift.sh -O - | /bin/sh"),
        ("OpenPli-9.0", "wget https://dreambox4u.com/emilnabil237/images/openpli-9.0.sh -O - | /bin/sh"),
       ("OpenPli-9.1", "wget https://dreambox4u.com/emilnabil237/images/openpli-9.1.sh -O - | /bin/sh"), ("OpenPli-develop", "wget https://dreambox4u.com/emilnabil237/images/openpli-develop.sh -O - | /bin/sh"),
        ("openspa-7.5.xxx", "wget https://dreambox4u.com/emilnabil237/images/openspa-7.5.xxx.sh -O - | /bin/sh"),
        ("openspa-8.0.xxx", "wget https://dreambox4u.com/emilnabil237/images/openspa-8.0.xxx.sh -O - | /bin/sh"),
        ("openspa-8.1.xxx", "wget https://dreambox4u.com/emilnabil237/images/openspa-8.1.xxx.sh -O - | /bin/sh"),
        ("openspa-8.3.xxx", "wget https://dreambox4u.com/emilnabil237/images/openspa-8.3.xxx.sh -O - | /bin/sh"),
        ("openspa-8.4.xxx", "wget https://dreambox4u.com/emilnabil237/images/openspa-8.4.xxx.sh -O - | /bin/sh"),
        ("Openvix-6.6.004", "wget https://dreambox4u.com/emilnabil237/images/openvix-6.6.004.sh -O - | /bin/sh"),
        ("openvix_latest-version", "wget https://dreambox4u.com/emilnabil237/images/openvix_latest-version.sh -O - | /bin/sh"),
        ("OpenVision-py2-10.3-r395", "wget https://dreambox4u.com/emilnabil237/images/openvision/OpenVision-py2-10.3-r395.sh -O - | /bin/sh"),
        ("pure2-7.4", "wget https://dreambox4u.com/emilnabil237/images/pure2-7.4.sh -O - | /bin/sh"),
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
        ("Cccam", "wget https://dreambox4u.com/emilnabil237/emu/installer-cccam.sh -O - | /bin/sh"),
        ("gosatplus-ncam", "wget https://dreambox4u.com/emilnabil237/emu/installer-gosatplus-ncam.sh -O - | /bin/sh"),
        ("gosatplus-oscam", "wget https://dreambox4u.com/emilnabil237/emu/installer-gosatplus-oscam.sh -O - | /bin/sh"),
        ("gosatplus_v3_arm", "wget http://e2.gosatplus.com/Plugin/V3/arm-openpli-installer_py3_v3.sh -O - | /bin/sh"),
        ("gosatplus_v3_mips", "wget http://e2.gosatplus.com/Plugin/V3/mips-openpli-installer_py3_v3.sh -O - | /bin/sh"),
        ("gosatplus_v3_Fix", "wget http://e2.gosatplus.com/Plugin/V3/GosatPlusPluginFixPy.sh -O - | /bin/sh"),
        ("Hold-flag-ncam", "opkg flag hold enigma2-plugin-softcams-ncam"),
        ("Hold-flag-Oscam", "opkg flag hold enigma2-plugin-softcams-oscam"),
        ("Ncam", "wget https://dreambox4u.com/emilnabil237/emu/installer-ncam.sh -O - | /bin/sh"),
        ("Oscam", "wget https://dreambox4u.com/emilnabil237/emu/installer-oscam.sh -O - | /bin/sh"),
        ("Oscam-11.726-by-lenuxsat", "wget https://dreambox4u.com/emilnabil237/emu/oscam-by-lenuxsat/installer.sh -O - | /bin/sh"),
        ("oscamicam", "wget https://dreambox4u.com/emilnabil237/emu/installer-oscamicam.sh -O - | /bin/sh"),
        ("powercam_v2-icam-arm", "wget https://dreambox4u.com/emilnabil237/emu/powercam/installer.sh -O - | /bin/sh"),
        ("powercam-Ncam", "wget https://dreambox4u.com/emilnabil237/emu/installer-powercam-ncam.sh -O - | /bin/sh"),
        ("powercam-Oscam", "wget https://dreambox4u.com/emilnabil237/emu/installer-powercam-oscam.sh -O - | /bin/sh"),
        ("Restore-flag-ncam", "opkg flag user enigma2-plugin-softcams-ncam"),
        ("Restore-flag-oscam", "opkg flag user enigma2-plugin-softcams-oscam"),
        ("Revcam-Ncam", "wget https://dreambox4u.com/emilnabil237/emu/installer-revcam-ncam.sh -O - | /bin/sh"),
        ("Revcam-Oscam", "wget https://dreambox4u.com/emilnabil237/emu/installer-revcam-oscam.sh  -O - | /bin/sh"),
        ("Revcam", "wget https://dreambox4u.com/emilnabil237/emu/installer-revcam.sh -O - | /bin/sh"),
        ("Supcam-Ncam", "wget https://dreambox4u.com/emilnabil237/emu/installer-supcam-ncam.sh -O - | /bin/sh"),
        ("Supcam-Oscam", "wget https://dreambox4u.com/emilnabil237/emu/installer-supcam-oscam.sh  -O - | /bin/sh"),
        ("Ultracam-Ncam", "wget https://dreambox4u.com/emilnabil237/emu/installer-ultracam-ncam.sh -O - | /bin/sh"),
        ("Ultracam-Oscam", "wget https://dreambox4u.com/emilnabil237/emu/installer-ultracam-oscam.sh -O - | /bin/sh"),
        ("Ultracam", "wget https://dreambox4u.com/emilnabil237/emu/installer-ultracam.sh -O - | /bin/sh"),
    ],
    "Channels-other": [
        ("Elsafty-Tv-Radio-Steaming", "wget https://dreambox4u.com/emilnabil237/settings/elsafty/installer.sh -O - | /bin/sh"),
        ("Khaled Ali", "wget https://raw.githubusercontent.com/emilnabil/channel-khaled/main/installer.sh -qO - | /bin/sh"),
        ("Mohamed Goda", "wget https://raw.githubusercontent.com/emilnabil/channel-mohamed-goda/main/installer.sh  -O - | /bin/sh"),
        ("Emil Nabil", "wget https://raw.githubusercontent.com/emilnabil/channel-emil-nabil/main/installer.sh -O - | /bin/sh"),
        ("Mohamed Os", "wget https://gitlab.com/MOHAMED_OS/dz_store/-/raw/main/Settings_Enigma2/online-setup | bash"),
        ("Tarek Ashry", "wget https://raw.githubusercontent.com/emilnabil/channel-tarek-ashry/main/installer.sh -qO - | /bin/sh"),
    ],
    "Channels_Siefp_E2": [
        ("ciefp-channels-e2-75e-34w", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/ciefp-channels-e2/ciefp-channels-e2-75e-34w.sh -O - | /bin/sh"),
        ("ciefp-E2-1sat-19E", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/ciefp-channels-e2/ciefp-E2-1sat-19E.sh -qO - | /bin/sh"),
        ("ciefp-E2-2satA-19E-13E", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/ciefp-channels-e2/ciefp-E2-2satA-19E-13E.sh -O - | /bin/sh"),
        ("ciefp-E2-2satB-19E-16E", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/ciefp-channels-e2/ciefp-E2-2satB-19E-16E.sh -O - | /bin/sh"),
        ("ciefp-E2-3satA-9E-10E-13E", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/ciefp-channels-e2/ciefp-E2-3satA-9E-10E-13E.sh -O - | /bin/sh"),
        ("ciefp-E2-3satB-19E-16E-13E", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/ciefp-channels-e2/ciefp-E2-3satB-19E-16E-13E.sh -O - | /bin/sh"),
        ("ciefp-E2-4satA-28E-19E-13E-30W", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/ciefp-channels-e2/ciefp-E2-4satA-28E-19E-13E-30W.sh -O - | /bin/sh"),
        ("ciefp-E2-4satB-19E-16E-13E-0.8W", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/ciefp-channels-e2/ciefp-E2-4satB-19E-16E-13E-0.8W.sh -O - | /bin/sh"),
        ("ciefp-E2-5sat-19E-16E-13E-1.9E-0.8W", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/ciefp-channels-e2/ciefp-E2-5sat-19E-16E-13E-1.9E-0.8W.sh -O - | /bin/sh"),
        ("ciefp-E2-6sat-23E-19E-16E-13E-1.9E-0.8W", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/ciefp-channels-e2/ciefp-E2-6sat-23E-19E-16E-13E-1.9E-0.8W.sh -O - | /bin/sh"),
        ("ciefp-E2-7sat-23E-19E-16E-13E-4.8E-1.9E-0.8W", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/ciefp-channels-e2/ciefp-E2-7sat-23E-19E-16E-13E-4.8E-1.9E-0.8W.sh -O - | /bin/sh"),
        ("ciefp-E2-8sat-28E-23E-19E-16E-13E-4.8E-1.9E-0.8W", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/ciefp-channels-e2/ciefp-E2-8sat-28E-23E-19E-16E-13E-4.8E-1.9E-0.8W.sh -O - | /bin/sh"),
        ("ciefp-E2-9sat-28E-23E-19E-16E-13E-9E-1.9E-0.8W-5W", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/ciefp-channels-e2/ciefp-E2-9sat-28E-23E-19E-16E-13E-9E-1.9E-0.8W-5W.sh -O - | /bin/sh"),
        ("ciefp-E2-10sat-39E-28E-23E-19E-16E-13E-9E-4.8E-1.9E-0.8W", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/ciefp-channels-e2/ciefp-E2-10sat.sh -O - | /bin/sh"),
        ("ciefp-E2-13sat-42E-39E-28E-23E-19E-16E-13E-9E-7E-4.8E-1.9E-0.8w-5w", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/ciefp-channels-e2/ciefp-E2-13sat.sh -O - | /bin/sh"),
        ("ciefp-E2-16sat-42E-39E-28E-26E-23E-19E-16E-13E-10E-9E-7E-4.8E-1.9E-0.8w-4W-5w", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/ciefp-channels-e2/ciefp-E2-16sat.sh -O - | /bin/sh"),
        ("ciefp-E2-18sat-42E-39E-36E-33E-28E-26E-23E-19E-16E-13E-10E-9E-7E-4.8E-1.9E-0.8w-4W-5w", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/ciefp-channels-e2/ciefp-E2-18sat.sh -O - | /bin/sh"),
    ],    
    "Channels-Vanenbal": [
        ("Vhannibal-Dual-13-19E", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/vanenbal-channels/Vhannibal-Dual-13-19E.sh -O - | /bin/sh"),
        ("Vhannibal-Dual-DTT-Campania", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/vanenbal-channels/Vhannibal-Dual-DTT-Campania.sh -qO - | /bin/sh"),
        ("Vhannibal-Dual-DTT-Italia", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/vanenbal-channels/Vhannibal-Dual-DTT-Italia.sh -O - | /bin/sh"),
        ("Vhannibal-Dual-DTT-Lazio", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/vanenbal-channels/Vhannibal-Dual-DTT-Lazio.sh -O - | /bin/sh"),
        ("Vhannibal-Dual-DTT-Lombardia", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/vanenbal-channels/Vhannibal-Dual-DTT-Lombardia.sh -O - | /bin/sh"),
        ("Vhannibal-Dual-DTT-Piemonte", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/vanenbal-channels/Vhannibal-Dual-DTT-Piemonte.sh -O - | /bin/sh"),
        ("Vhannibal-HotBird-13E", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/vanenbal-channels/Vhannibal-HotBird-13E.sh -O - | /bin/sh"),
        ("Vhannibal-HotBird-DTT-Campania", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/vanenbal-channels/Vhannibal-HotBird-DTT-Campania.sh -O - | /bin/sh"),
        ("Vhannibal-HotBird-DTT-Italia", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/vanenbal-channels/Vhannibal-HotBird-DTT-Italia.sh -O - | /bin/sh"),
        ("Vhannibal-HotBird-DTT-Lazio", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/vanenbal-channels/Vhannibal-HotBird-DTT-Lazio.sh -O - | /bin/sh"),
        ("Vhannibal-HotBird-DTT-Lombardia", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/vanenbal-channels/Vhannibal-HotBird-DTT-Lombardia.sh -O - | /bin/sh"),
        ("Vhannibal-HotBird-DTT-Piemonte", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/vanenbal-channels/Vhannibal-HotBird-DTT-Piemonte.sh -O - | /bin/sh"),
        ("Vhannibal-Motor-70E-45W", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/vanenbal-channels/Vhannibal-Motor-70E-45W.sh -O - | /bin/sh"),
        ("Vhannibal-Motor-DTT-Campania", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/vanenbal-channels/Vhannibal-Motor-DTT-Campania.sh -O - | /bin/sh"),
        ("Vhannibal-Motor-DTT-Italia", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/vanenbal-channels/Vhannibal-Motor-DTT-Italia.sh -O - | /bin/sh"),
        ("Vhannibal-Motor-DTT-Lazio", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/vanenbal-channels/Vhannibal-Motor-DTT-Lazio.sh -O - | /bin/sh"),
        ("Vhannibal-Motor-DTT-Lombardia", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/vanenbal-channels/Vhannibal-Motor-DTT-Lombardia.sh -O - | /bin/sh"),
        ("Vhannibal-Motor-DTT-Piemonte", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/vanenbal-channels/Vhannibal-Motor-DTT-Piemonte.sh -O - | /bin/sh"),
        ("Vhannibal-Motor-DTT-Romagna", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/vanenbal-channels/Vhannibal-Motor-DTT-Romagna.sh -O - | /bin/sh"),
        ("Vhannibal-Motor-DTT-Sardegna", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/vanenbal-channels/Vhannibal-Motor-DTT-Sardegna.sh -O - | /bin/sh"),
        ("Vhannibal-Motor-DTT-Sicilia", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/vanenbal-channels/Vhannibal-Motor-DTT-Sicilia.sh -O - | /bin/sh"),
        ("Vhannibal-Quadri-9-13-16-19-23E", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/vanenbal-channels/Vhannibal-Quadri-9-13-16-19-23E.sh -O - | /bin/sh"),
        ("Vhannibal-Quadri-13-19-5E-1W", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/vanenbal-channels/Vhannibal-Quadri-13-19-5E-1W.sh -O - | /bin/sh"),
        ("Vhannibal-Quadri-13-19-9E-5W", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/vanenbal-channels/Vhannibal-Quadri-13-19-9E-5W.sh -O - | /bin/sh"),
        ("Vhannibal-Quadri-13-19-23-28E", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/vanenbal-channels/Vhannibal-Quadri-13-19-23-28E.sh -O - | /bin/sh"),
        ("Vhannibal-Trial-13-19E-5W", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/vanenbal-channels/Vhannibal-Trial-13-19E-5W.sh -O - | /bin/sh"),
       ("Vhannibal-Trial-13-19E-30W", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/vanenbal-channels/Vhannibal-Trial-13-19E-30W.sh -O - | /bin/sh"), 
    ],
    "Channels-morpheus883": [
        ("Morph883_0.8W-4.8E-13E", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/morpheus883-channels/E2_Morph883_0.8W-4.8E-13E.sh -O - | /bin/sh"),
        ("Morph883_0.8W-13E-19.2E-28.2E", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/morpheus883-channels/E2_Morph883_0.8W-13E-19.2E-28.2E.sh -qO - | /bin/sh"),
        ("Morph883_0.8W-13E-19.2E", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/morpheus883-channels/E2_Morph883_0.8W-13E-19.2E.sh -O - | /bin/sh"),
        ("Morph883_0.8W-13E", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/morpheus883-channels/E2_Morph883_0.8W-13E.sh -O - | /bin/sh"),
        ("Morph883_4.8E-13E-19.2E", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/morpheus883-channels/E2_Morph883_4.8E-13E-19.2E.sh -O - | /bin/sh"),
        ("Morph883_4.8E-13E", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/morpheus883-channels/E2_Morph883_4.8E-13E.sh -O - | /bin/sh"),
        ("Morph883_9E-13E-19.2E", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/morpheus883-channels/E2_Morph883_9E-13E-19.2E.sh -O - | /bin/sh"),
        ("Morph883_9E-13E", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/morpheus883-channels/E2_Morph883_9E-13E.sh -O - | /bin/sh"),
        ("Morph883_13E-16E-19.2E", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/morpheus883-channels/E2_Morph883_13E-16E-19.2E.sh -O - | /bin/sh"),
        ("Morph883_13E-16E", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/morpheus883-channels/E2_Morph883_13E-16E.sh -O - | /bin/sh"),
        ("Morph883_13E-19.2E-23.5E-28.2E", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/morpheus883-channels/E2_Morph883_13E-19.2E-23.5E-28.2E.sh -O - | /bin/sh"),
        ("Morph883_13E-19.2E-23.5E", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/morpheus883-channels/E2_Morph883_13E-19.2E-23.5E.sh -O - | /bin/sh"),
        ("Morph883_13E-19.2E-28.2E", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/morpheus883-channels/E2_Morph883_13E-19.2E-28.2E.sh -O - | /bin/sh"),
        ("Morph883_13E-19.2E-42E", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/morpheus883-channels/E2_Morph883_13E-19.2E-42E.sh -O - | /bin/sh"),
        ("Morph883_13E-19.2E.sh", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/morpheus883-channels/E2_Morph883_13E-19.2E.sh -O - | /bin/sh"),
        ("Morph883_13E-23.5E", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/morpheus883-channels/E2_Morph883_13E-23.5E.sh -O - | /bin/sh"),
        ("Morph883_13E-28.2E", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/morpheus883-channels/E2_Morph883_13E-28.2E.sh -O - | /bin/sh"),
        ("Morph883_13E-42E", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/morpheus883-channels/E2_Morph883_13E-42E.sh -O - | /bin/sh"),
        ("Morph883_13E", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/morpheus883-channels/E2_Morph883_13E.sh -O - | /bin/sh"),
        ("Morph883_30W-13E-19.2E", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/morpheus883-channels/E2_Morph883_30W-13E-19.2E.sh -O - | /bin/sh"),
        ("Morph883_30W-13E", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/morpheus883-channels/E2_Morph883_30W-13E.sh -O - | /bin/sh"),
        ("Morph883_Motor", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/morpheus883-channels/E2_Morph883_Motor.sh -O - | /bin/sh"),
        ("Morph883_Settings", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/morpheus883-channels/E2_Morph883_Settings.sh -O - | /bin/sh"),
    ],
    "Key Plugins": [
        
("Auto-Dcw-Key-Add", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/auto-dcw-key-add/auto-dcw-key-add.sh -O - | /bin/sh"),
("BissFeedAutoKey", "wget https://raw.githubusercontent.com/emilnabil/bissfeed-autokey/main/installer.sh -O - | /bin/sh"),
        ("feeds-finder", "wget https://dreambox4u.com/emilnabil237/plugins/feeds-finder/installer.sh  -O - | /bin/sh"),
        ("KeyAdder", "wget https://dreambox4u.com/emilnabil237/plugins/KeyAdder/installer.sh -O - | /bin/sh"),
    ],
    "Multiboot Plugins": [
        ("EgamiBoot_10.5", "wget https://raw.githubusercontent.com/emil237/egamiboot/refs/heads/main/installer.sh  -O - | /bin/sh"),
        ("EgamiBoot_10.6", "wget https://raw.githubusercontent.com/emil237/egamiboot/refs/heads/main/egamiboot-10.6.sh -O - | /bin/sh"),
        ("Neoboot_9.65", "wget https://dreambox4u.com/emilnabil237/plugins/neoboot-v9.65/iNB.sh  -O - | /bin/sh"),
        ("Neoboot_9.65_Mod-By-ElSafty", "wget https://raw.githubusercontent.com/emil237/neoboot_v9.65/main/iNB_9.65_mod-elsafty.sh  -O - | /bin/sh"),
        ("Neoboot_9.60", "wget https://dreambox4u.com/emilnabil237/plugins/neoboot-v9.60/iNB.sh  -O - | /bin/sh"),
        ("Neoboot_9.58", "wget https://dreambox4u.com/emilnabil237/plugins/neoboot-v9.58/iNB.sh -O - | /bin/sh"),
        ("Neoboot_9.54", "wget https://raw.githubusercontent.com/emil237/neoboot_9.54/main/installer.sh  -O - | /bin/sh"),
        ("OpenMultiboot_1.3", "wget https://raw.githubusercontent.com/emil237/openmultiboot/main/installer.sh  -O - | /bin/sh"),
        ("OpenMultiboot-E2turk", "wget https://raw.githubusercontent.com/e2TURK/omb-enhanced/main/install.sh  -O - | /bin/sh"),
        ("Multiboot-FlashOnline", "wget https://raw.githubusercontent.com/emil237/download-plugins/main/multiboot-flashonline.sh -O - | /bin/sh"),
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
    "Display-Skin": [
                ("display-oe-a-lcdskin-1", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/Display-Skin/display-oe-a-lcdskin-1.sh -O - | /bin/sh"),
        ("display-oe-a-lcdskin-2", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/Display-Skin/display-oe-a-lcdskin-2.sh -O - | /bin/sh"),
        ("display-oe-a-lcdskin-3", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/Display-Skin/display-oe-a-lcdskin-3.sh -O - | /bin/sh"),
        ("display-oe-a-lcdskin-4", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/Display-Skin/display-oe-a-lcdskin-4.sh -O - | /bin/sh"),
        ("display-oe-a-lcdskin-5", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/Display-Skin/display-oe-a-lcdskin-5.sh -O - | /bin/sh"),
        ("display-oe-a-lcdskin-6", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/Display-Skin/display-oe-a-lcdskin-6.sh -O - | /bin/sh"),
        ("display-oe-a-lcdskin-7", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/Display-Skin/display-oe-a-lcdskin-7.sh -O - | /bin/sh"),
        ("display-oe-a-lcdskin-8", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/Display-Skin/display-oe-a-lcdskin-8.sh -O - | /bin/sh"),
        ("display-oe-a-lcdskin-9", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/Display-Skin/display-oe-a-lcdskin-9.sh -O - | /bin/sh"),
     ("display-oe-a-lcdskin-10", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/display-oe-a-lcdskin-10.sh -O - | /bin/sh"), 
     ("display-oe-a-lcdskin-11", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/display-oe-a-lcdskin-11.sh -O - | /bin/sh"), 
       ("display-oe-a-lcdskin-12", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/display-oe-a-lcdskin-12.sh -O - | /bin/sh"), 
       ("display-oe-a-lcdskin-13", "wget https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/display-oe-a-lcdskin-13.sh -O - | /bin/sh"), 
    ],
    "Backup-Settengs-Menu": [
          ("Backup-my-shannels", "wget http://dreambox4u.com/emilnabil237/script/Create-My-backup-shannels.sh -O - | /bin/sh"),   
         ("Backup-hotkey", "wget http://dreambox4u.com/emilnabil237/script/backup-hotkey.sh -O - | /bin/sh"),
         ("Backup-network", "wget http://dreambox4u.com/emilnabil237/script/backup-network.sh -O - | /bin/sh"),
         ("Backup-softcams", "wget http://dreambox4u.com/emilnabil237/script/backup-softcams.sh -O - | /bin/sh"),
        ("Backup-tuner", "wget http://dreambox4u.com/emilnabil237/script/backup-tuner.sh -O - | /bin/sh"),
        ("Backup-my-bouquetmakerxtream", "wget http://dreambox4u.com/emilnabil237/script/backup-my-bouquetmakerxtream.sh -O - | /bin/sh"),
        ("Backup-my-ip2sat-server", "wget http://dreambox4u.com/emilnabil237/script/backup-my-ip2sat-server.sh -O - | /bin/sh"),
("Backup-my-ipaudio-server", "wget http://dreambox4u.com/emilnabil237/script/backup-my-ipaudio-server.sh -O - | /bin/sh"),
("Backup-my-ipaudiopro-server", "wget http://dreambox4u.com/emilnabil237/script/backup-my-ipaudiopro-server.sh -O - | /bin/sh"),
        ("Backup-my-jediplaylists", "wget http://dreambox4u.com/emilnabil237/script/backup-my-jediplaylists.sh -O - | /bin/sh"),
        ("Backup-my-multistalkerpro", "wget http://dreambox4u.com/emilnabil237/script/backup-my-multistalkerpro.sh -O - | /bin/sh"),
        ("Backup-my-Subtitle-Setting", "wget http://dreambox4u.com/emilnabil237/script/backup_my-subtitle-setting.sh -O - | /bin/sh"),
        ("Backup-my-xstreamity-servers", "wget http://dreambox4u.com/emilnabil237/script/backup-my-xstreamity-servers.sh -O - | /bin/sh"),
        ("Backup-sittings-xtraevent", "wget http://dreambox4u.com/emilnabil237/script/backup-sittings-xtraevent.sh -O - | /bin/sh"),
    ],
     "Restore-Settengs-Menu": [
          ("Restore-my-shannels", "wget http://dreambox4u.com/emilnabil237/script/Restore-My-backup-shannels.sh -O - | /bin/sh"),   
         ("Restore-hotkey", "wget http://dreambox4u.com/emilnabil237/script/resore-hotkey.sh -O - | /bin/sh"),
         ("Restore-network", "wget http://dreambox4u.com/emilnabil237/script/restore-network.sh -O - | /bin/sh"),
         ("Restore-softcams", "wget http://dreambox4u.com/emilnabil237/script/restore-softcams.sh -O - | /bin/sh"),
        ("Restore-tuner", "wget http://dreambox4u.com/emilnabil237/script/restore-tuner.sh -O - | /bin/sh"),
        ("Restore-my-bouquetmakerxtream", "wget http://dreambox4u.com/emilnabil237/script/restore-my-bouquetmakerxtream.sh -O - | /bin/sh"),
        ("Restore-my-ip2sat-server", "wget http://dreambox4u.com/emilnabil237/script/restore-my-ip2sat-server.sh -O - | /bin/sh"),
  ("Restore-my-ipaudio-server", "wget http://dreambox4u.com/emilnabil237/script/restore-my-ipaudio-server.sh -O - | /bin/sh"),
("Restore-my-ipaudiopro-server", "wget http://dreambox4u.com/emilnabil237/script/restore-my-ipaudiopro-server.sh -O - | /bin/sh"),
        ("Restore-my-jediplaylists", "wget http://dreambox4u.com/emilnabil237/script/restore-my-jediplaylists.sh -O - | /bin/sh"),
        ("Restore-my-multistalkerpro", "wget http://dreambox4u.com/emilnabil237/script/restore-my-multistalkerpro.sh -O - | /bin/sh"),
        ("Restore-My-Subtitle-Setting", "wget http://dreambox4u.com/emilnabil237/script/Restore_my-subtitle-setting.sh -O - | /bin/sh"),
        ("Restore-my-xstreamity-servers", "wget http://dreambox4u.com/emilnabil237/script/restore-my-xstreamity-servers.sh -O - | /bin/sh"),
        ("Restore-sittings-xtraevent", "wget http://dreambox4u.com/emilnabil237/script/restore-sittings-xtraevent.sh -O - | /bin/sh"),
    ],
    "Skins Other": [
        ("Aglare-FHD for Atv-Spa-Egami", "wget https://raw.githubusercontent.com/popking159/skins/refs/heads/main/aglareatv/installer.sh -O - | /bin/sh"),
        ("Aglare-FHD for Pli-OBH-Vix", "wget https://raw.githubusercontent.com/popking159/skins/refs/heads/main/aglarepli/installer.sh -O - | /bin/sh"),
        ("XDreamy-FHD", "wget https://raw.githubusercontent.com/Insprion80/Skins/main/xDreamy/installer.sh -O - | /bin/sh"),
    ],
    "Skins TeamNitro": [
        ("TeamNitro Control", "wget https://gitlab.com/emilnabil1/teamnitro/-/raw/main/SKIN-teamnitro.sh -O - | /bin/sh"),
        ("AlAyam-FHD", "wget https://raw.githubusercontent.com/biko-73/TeamNitro/main/script/installerAL.sh -O - | /bin/sh"),
        ("Desert-FHD", "wget https://gitlab.com/emilnabil1/teamnitro/-/raw/main/installer-skin-desert.sh -O - | /bin/sh"),
   ("BoHLALA-FHD", "wget https://gitlab.com/emilnabil1/teamnitro/-/raw/main/installer.sh -O - | /bin/sh"),
        ("Dragon-FHD", "wget https://raw.githubusercontent.com/biko-73/TeamNitro/main/script/installerD.sh -O - | /bin/sh"),
        ("NitroAdvance-FHD", "wget https://raw.githubusercontent.com/biko-73/TeamNitro/main/script/installerN.sh -O - | /bin/sh"),
    ("Klll-Pro-FHD", "wget https://raw.githubusercontent.com/biko-73/zelda77/main/installer.sh -O - | /bin/sh"),
    ],
    "Skins Atv": [
        ("Aglare-FHD", "wget https://raw.githubusercontent.com/popking159/skins/refs/heads/main/aglareatv/installer.sh -O - | /bin/sh"),
        ("Areadeltasat_fhd", "wget https://github.com/emil237/skins-enigma2/raw/refs/heads/main/ATV/skins_areadeltasat_fhd_dragon_1_9_Poster_Backdrop.sh -O - | /bin/sh"),
("Fury-FHD", "wget https://raw.githubusercontent.com/islam-2412/IPKS/refs/heads/main/fury/installer.sh -O - | /bin/sh"),
        ("Maxy-FHD", "wget https://raw.githubusercontent.com/popking159/skins/refs/heads/main/maxyatv/installer.sh -O - | /bin/sh"),
        ("Full HD Glass17", "wget http://dreambox4u.com/emilnabil237/skins/skin-fullhdglass17/installer.sh -O - | /bin/sh"),
   ("MyMetrixLiteBackup", "wget -O /etc/enigma2/MyMetrixLiteBackup.dat https://dreambox4u.com/emilnabil237/plugins/metrix-fhd/khaled_metrix/MyMetrixLiteBackup.dat"),
        ("MetrixFHD-Extraevent-PosterXD", "wget https://dreambox4u.com/emilnabil237/skins/openatv/SKIN-MetrixFHD-OpenATV-Extraevent-PosterX.sh -O - | /bin/sh"),
        ("malek-fhd", "wget https://raw.githubusercontent.com/emil237/skins-enigma2/main/ATV/skins-malek-fhd_2.2_py3.11.2-py3.12.1.sh -O - | /bin/sh"),
    ("Nacht_1.7.3", "wget http://dreambox4u.com/emilnabil237/script/SKIN-ATV-nacht_1.7.3.sh -O - | /bin/sh"),
     ("Ozeta-Xtra", "wget http://dreambox4u.com/emilnabil237/script/SKIN-ATV-ozeta-xtra.sh -O - | /bin/sh"),
      ("XDreamy-FHD", "wget https://raw.githubusercontent.com/Insprion80/Skins/main/xDreamy/installer.sh -O - | /bin/sh"),
    ],
      "Skins Egami": [
        ("Aglare-FHD", "wget https://raw.githubusercontent.com/popking159/skins/refs/heads/main/aglareatv/installer.sh -O - | /bin/sh"),
("Fury-FHD", "wget https://raw.githubusercontent.com/islam-2412/IPKS/refs/heads/main/fury/installer.sh -O - | /bin/sh"),
        ("Premium-Fhd", "wget https://dreambox4u.com/emilnabil237/skins/script/SKIN-egami-premium-fhd-py3.sh -O - | /bin/sh"),
        ("Premium-Black-Fhd", "wget https://dreambox4u.com/emilnabil237/skins/script/SKIN-egami-premium--black-fhd-py3.sh -O - | /bin/sh"),
        ("Premium-Blue-Fhd", "wget https://dreambox4u.com/emilnabil237/skins/script/SKIN-egami-premium--blue-fhd-py3.sh -O - | /bin/sh"),
   ("XDreamy-FHD", "wget https://raw.githubusercontent.com/Insprion80/Skins/main/xDreamy/installer.sh -O - | /bin/sh"),
     ],
"Skins Open BlackHole": [
                ("Aglare-fhd", "wget https://raw.githubusercontent.com/popking159/skins/refs/heads/main/aglarepli/installer.sh -O - | /bin/sh"),
("Fury-FHD", "wget https://raw.githubusercontent.com/islam-2412/IPKS/refs/heads/main/fury/installer.sh -O - | /bin/sh"),
        ("MX_BlackSea", "wget https://dreambox4u.com/emilnabil237/skins/obh/skins-MX_BlackSea.sh -O - | /bin/sh"),
        ("MX-Sline-Black-Red-Gradient", "wget https://dreambox4u.com/emilnabil237/skins/obh/mx-sline-black-red-gradient_py3.12.sh -O - | /bin/sh"),
        ("MX_Sline-Blue", "wget https://dreambox4u.com/emilnabil237/skins/obh/MX_Sline-Blue_OBH_5.4_py3.12_py3.12.sh -O - | /bin/sh"),
        ("MX_Sline-Red_X2", "wget https://dreambox4u.com/emilnabil237/skins/obh/MX_Sline-Red_X2_py3.12.sh -O - | /bin/sh"),
        ("OpenBhGreenFHD", "wget https://dreambox4u.com/emilnabil237/skins/obh/skin_OpenBhGreenFHD.sh -O - | /bin/sh"),
   ("XDreamy-FHD", "wget https://raw.githubusercontent.com/Insprion80/Skins/main/xDreamy/installer.sh -O - | /bin/sh"),
 ("Youchie-OBH-FHD", "wget https://raw.githubusercontent.com/emilnabil/skins-obh/refs/heads/main/skin-Youchie-OBH-FHD.sh -O - | /bin/sh"),  
    ],
 "Skins OpenPli Py3": [
                ("Aglare-fhd", "wget https://raw.githubusercontent.com/popking159/skins/refs/heads/main/aglarepli/installer.sh -O - | /bin/sh"),
        ("BARDO-FHD", "wget https://raw.githubusercontent.com/emil237/skins-enigma2/refs/heads/main/pli/Skin-bardo-fhd_3.7.2.sh -O - | /bin/sh"),
        ("BLACKNEON-XP_Mod_M-Nasr", "wget https://dreambox4u.com/emilnabil237/skins/pli9x/Skin-BLACKNEON-XP_mod_mnasr-pli9x.sh -O - | /bin/sh"),
        ("malek-fhd", "wget https://raw.githubusercontent.com/emil237/skins-enigma2/main/pli/Skin-malek-fhd_1.2.sh -O - | /bin/sh"),
        ("Ozeta-Xtra", "wget http://dreambox4u.com/emilnabil237/script/SKIN-PLI-ozeta-xtra.sh -O - | /bin/sh"),
   ("XDreamy-FHD", "wget https://raw.githubusercontent.com/Insprion80/Skins/main/xDreamy/installer.sh -O - | /bin/sh"),
   ("Youchie-PLI-FHD", "wget https://raw.githubusercontent.com/emilnabil/skins-openpli-9x/refs/heads/main/skin-Youchie-PLI-FHD.sh -O - | /bin/sh"),
  ],
    "Skins OpenVix": [
        ("Aglare-FHD", "wget https://raw.githubusercontent.com/popking159/skins/refs/heads/main/aglarepli/installer.sh -O - | /bin/sh"),
("Fury-FHD", "wget https://raw.githubusercontent.com/islam-2412/IPKS/refs/heads/main/fury/installer.sh -O - | /bin/sh"),
        ("XDreamy-FHD", "wget https://raw.githubusercontent.com/Insprion80/Skins/main/xDreamy/installer.sh -qO - | /bin/sh"),
    ],
      "Skins OpenSpa": [
        ("Aglare-FHD", "wget https://raw.githubusercontent.com/popking159/skins/refs/heads/main/aglareatv/installer.sh -O - | /bin/sh"),
("Fury-FHD", "wget https://raw.githubusercontent.com/islam-2412/IPKS/refs/heads/main/fury/installer.sh -O - | /bin/sh"),        ("estuary-1080-FHD", "wget https://gitlab.com/elbrins/skins/-/raw/main/Spa/Skin-estuary-1080.sh -qO - | /bin/sh"),
    ],
    "Skins OpenPli Py2": [
        ("Bluemetal-FHD", "wget https://raw.githubusercontent.com/emil237/skins-enigma2/refs/heads/main/pli/Skin-bluemetal-fhd.sh -O - | /bin/sh"),
        ("CH.LEAGUE-FHD", "wget http://dreambox4u.com/emilnabil237/script/SKIN-PLI-CH.LEAGUE-FHD.sh -O - | /bin/sh"),
        ("Maxy-FHD", "wget https://dreambox4u.com/emilnabil237/skins/script/skins-Maxy-FHD.sh -O - | /bin/sh"),
        ("Ozeta-Xtra", "wget http://dreambox4u.com/emilnabil237/script/SKIN-PLI-ozeta-xtra.sh -O - | /bin/sh"),
   ("QATAR-2022-V3-FHD", "wget http://dreambox4u.com/emilnabil237/script/SKIN-PLI-QATAR-2022-V3-FHD.sh -O - | /bin/sh"),
        ("SPIDERMAN-FHD", "wget http://dreambox4u.com/emilnabil237/script/SKIN-PLI-SPIDERMAN-FHD.sh -O - | /bin/sh"),
        ("WAR-S-FHD", "wget http://dreambox4u.com/emilnabil237/script/SKIN-PLI-WAR-S-FHD.sh -O - | /bin/sh"),
    ("BLACKSKY-S-HD", "wget https://raw.githubusercontent.com/emil237/skins-enigma2/main/pli/SKIN-BLACKSKY-S-HD-MOD-By-Muaath.sh -O - | /bin/sh"),
     ("BLUESKY-S-HD", "wget https://raw.githubusercontent.com/emil237/skins-enigma2/main/pli/SKIN-BLUESKY-S-HD-MOD-By-Muaath.sh -O - | /bin/sh"),
      ("BATMAN-MP-HD", "wget https://raw.githubusercontent.com/emil237/skins-enigma2/main/pli/SKIN-BATMAN-MP-HD-By-Muaath.sh -O - | /bin/sh"),
       ("TOKYO2020-FHD", "wget https://raw.githubusercontent.com/emil237/skins-enigma2/main/pli/SKIN-TOKYO2020-FHD-By-Muaath.sh -O - | /bin/sh"),
    ],
     "Skins BlackHole": [
        ("q-purple", "wget https://dreambox4u.com/emilnabil237/skins/blackhole/SKIN-BLACKHOLE--q-purple.sh -O - | /bin/sh"),
        ("Alienaware-Obh4", "wget https://dreambox4u.com/emilnabil237/skins/blackhole/SKIN-BLACKHOLE-alienaware-obh4.sh -O - | /bin/sh"),
        ("Ekselancen", "wget https://dreambox4u.com/emilnabil237/skins/blackhole/SKIN-BLACKHOLE-ekselancen.sh -O - | /bin/sh"),
        ("Mx-Sline", "wget https://dreambox4u.com/emilnabil237/skins/blackhole/SKIN-BLACKHOLE-mx-sline.sh -O - | /bin/sh"),
        ("Mxgraphite", "wget https://dreambox4u.com/emilnabil237/skins/blackhole/SKIN-BLACKHOLE-mxgraphite.sh -O - | /bin/sh"),
        ("Q-Darkblue", "wget https://dreambox4u.com/emilnabil237/skins/blackhole/SKIN-BLACKHOLE-q-darkblue.sh -O - | /bin/sh"),
        ("Q-Fhd", "wget https://dreambox4u.com/emilnabil237/skins/blackhole/SKIN-BLACKHOLE--q-purple.sh -O - | /bin/sh"),
        ("Waves4", "wget https://dreambox4u.com/emilnabil237/skins/blackhole/SKIN-BLACKHOLE-waves4.sh -O - | /bin/sh")
    ],
    "Skins Vti": [
        ("Aeonfhdmod_sharp987", "wget https://dreambox4u.com/emilnabil237/skins/vti/SKIN-VTI-aeonfhdmod_sharp987_vti-r3.27.sh -O - | /bin/sh"),
        ("Blue-shadow-fhd", "wget https://dreambox4u.com/emilnabil237/skins/vti/SKIN-VTI-blue-shadow-fhd_3.5.sh -O - | /bin/sh"),
        ("Cerx-fhd", "wget https://dreambox4u.com/emilnabil237/skins/vti/SKIN-VTI-cerx-fhd.sh -O - | /bin/sh"),
        ("Full-hd_9.7", "wget https://dreambox4u.com/emilnabil237/skins/vti/SKIN-VTI-full-hd_9.7.sh -O - | /bin/sh"),
        ("Greenhexagon-fhd", "wget https://dreambox4u.com/emilnabil237/skins/vti/SKIN-VTI-greenhexagon-fhd.sh -O - | /bin/sh"),
        ("Linearfhd_v4.1.1", "wget https://dreambox4u.com/emilnabil237/skins/vti/SKIN-VTI-linearfhd_v4.1.1.sh -O - | /bin/sh"),
        ("Sky-fhd_3.6", "wget https://dreambox4u.com/emilnabil237/skins/vti/SKIN-VTI-Sky-fhd_3.6.sh -O - | /bin/sh"),
        ("Square-fhd_2.2", "wget https://dreambox4u.com/emilnabil237/skins/vti/SKIN-VTI-square-fhd_2.2.sh -O - | /bin/sh"),
        ("Zflatgyrfhd_Sharp987", "wget https://dreambox4u.com/emilnabil237/skins/vti/SKIN-VTI-zflatgyrfhd_sharp987_vti-r1.01.sh -O - | /bin/sh")
    ],
    "Themes": [
        ("Light", "wget -O /usr/lib/enigma2/python/Plugins/Extensions/SmartAddonspanel/plugin.py https://github.com/emilnabil/download-plugins/raw/refs/heads/main/SmartAddonspanel/Py3/plugin-gray.py"),
        ("Dark", "wget -O /usr/lib/enigma2/python/Plugins/Extensions/SmartAddonspanel/plugin.py https://github.com/emilnabil/download-plugins/raw/refs/heads/main/SmartAddonspanel/Py3/plugin-dark.py"),
        ("Indigo Blue", "wget -O /usr/lib/enigma2/python/Plugins/Extensions/SmartAddonspanel/plugin.py https://github.com/emilnabil/download-plugins/raw/refs/heads/main/SmartAddonspanel/Py3/plugin-blue.py")
    ]
}
        self.selected_plugins = []
        self.focus = "main_menu"

        self["main_menu"] = MenuList(self.main_menu)
        self["sub_menu"] = List([])
        self["status"] = Label("Select a category")
        self["key_green"] = Button("Install")
        self["key_yellow"] = Button("Update")
        self["key_blue"] = Button("Restart")
        self["python_version"] = Label(self.get_python_version())
        self["receiver_model"] = Label(self.get_receiver_model())
        self["image_type"] = Label(self.get_image_type())
        self["image_version"] = Label(self.get_image_version())
        self["cpu_info"] = Label(self.get_cpu_info())
        self["memory_info"] = Label(self.get_memory_info())
        self["storage_info"] = Label(self.get_storage_info())
        self["mount_info"] = Label(self.get_mount_info())
        self["ip_address"] = Label(self.get_router_ip())
        self["internet_status"] = Label(self.get_internet_status())

        self.checked_icon = LoadPixmap(resolveFilename(SCOPE_PLUGINS, "Extensions/SmartAddonspanel/icons/checked.png"))
        self.unchecked_icon = LoadPixmap(resolveFilename(SCOPE_PLUGINS, "Extensions/SmartAddonspanel/icons/unchecked.png"))

        self["actions"] = ActionMap(
            ["OkCancelActions", "DirectionActions", "ColorActions"],
            {
                "ok": self.handle_ok,
                "left": self.focus_main_menu,
                "right": self.focus_sub_menu,
                "cancel": self.exit,
                "green": self.execute_all_selected_plugins,
                "yellow": self.update_plugin,
                "blue": self.restart_enigma2,
                "up": self.navigate_up,
                "down": self.navigate_down,
            },
            -1
        )

        self["main_menu"].onSelectionChanged.append(self.load_sub_menu)
        self.update_sub_menu_list()

        self.timer = eTimer()
        self.timer.timeout.get().append(self.update_time)
        self.timer.start(1000)
        self.version_check_in_progress = False
        self.check_for_updates()

    def split_name(self, name):
        parts = name.split('-')
        if len(parts) <= 1:
            return (name, '')
        mid = len(parts) // 2
        return ('-'.join(parts[:mid]), '-'.join(parts[mid:]))

    def update_sub_menu_list(self):
        sel = self["main_menu"].getCurrent()
        items = []
        if sel in self.sub_menus:
            for entry in self.sub_menus[sel]:
                name, cmd = entry
                line1, line2 = self.split_name(name)
                icon = self.checked_icon if any(p[0] == name for p in self.selected_plugins) else self.unchecked_icon
                items.append((line1, line2, icon, name))
        self["sub_menu"].setList(items)

    def load_sub_menu(self):
        self.update_sub_menu_list()
        self["status"].setText(f"Category: {self['main_menu'].getCurrent()}")

    def get_router_ip(self):
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(("8.8.8.8", 80))
            ip = s.getsockname()[0]
            s.close()
            return f"IP: {ip}"
        except:
            return "IP not available"

    def get_python_version(self):
        return f"Python: {sys.version.split()[0]}"

    def get_receiver_model(self):
        try:
            return open("/etc/hostname").read().strip()
        except:
            return "Unknown Model"

    def get_image_type(self):
        try:
            with open("/etc/image-version") as f:
                for line in f:
                    if "creator" in line.lower():
                        return line.strip().replace("creator", "Image")
            return "Unknown Image"
        except:
            return "Unknown Image"

    def get_image_version(self):
        try:
            with open("/etc/image-version") as f:
                for line in f:
                    if "version" in line.lower():
                        return line.strip()
            return "Unknown Version"
        except:
            return "Unknown Version"

    def get_cpu_info(self):
        try:
            with open("/proc/cpuinfo") as f:
                for line in f:
                    if "Processor" in line or "model name" in line:
                        return line.split(":",1)[1].strip()
            return "Unknown CPU"
        except:
            return "Unknown CPU"

    def get_memory_info(self):
        try:
            total = free = 0
            with open("/proc/meminfo") as f:
                for line in f:
                    if "MemTotal" in line:
                        total = int(line.split()[1]) // 1024
                    elif "MemFree" in line:
                        free = int(line.split()[1]) // 1024
            return f"RAM: {total}MB Free: {free}MB"
        except:
            return "Unknown Memory"

    def get_storage_info(self):
        try:
            st = os.statvfs("/")
            total = st.f_blocks * st.f_frsize
            free = st.f_bfree * st.f_frsize
            total_gb = total / (1024 ** 3)
            free_gb = free / (1024 ** 3)
            used_gb = total_gb - free_gb
            return f"HDD: {used_gb:.2f}GB/{total_gb:.2f}GB"
        except:
            return "HDD: N/A"

    def get_mount_info(self):
        return "Mount: /media/hdd" if os.path.ismount("/media/hdd") else "Mount: Not Found"

    def get_internet_status(self):
        return "Internet: Connected" if os.system("ping -c 1 8.8.8.8 >/dev/null 2>&1") == 0 else "Internet: Offline"

    def focus_main_menu(self):
        self.focus = "main_menu"
        self["main_menu"].selectionEnabled(1)
        self["sub_menu"].setIndex(0)

    def focus_sub_menu(self):
        self.focus = "sub_menu"
        self["main_menu"].selectionEnabled(0)
        if len(self["sub_menu"].list):
            self["sub_menu"].setIndex(0)

    def navigate_up(self):
        if self.focus == "main_menu":
            self["main_menu"].up()
        else:
            self["sub_menu"].up()

    def navigate_down(self):
        if self.focus == "main_menu":
            self["main_menu"].down()
        else:
            self["sub_menu"].down()

    def handle_ok(self):
        category = self["main_menu"].getCurrent()
        entry = self["sub_menu"].getCurrent()
        if not entry:
            return
        original_name = entry[3]
        cmd = next((c for n, c in self.sub_menus[category] if n == original_name), None)
        if cmd:
            if any(p[0] == original_name for p in self.selected_plugins):
                self.selected_plugins = [p for p in self.selected_plugins if p[0] != original_name]
            else:
                self.selected_plugins.append((original_name, cmd))
            self.update_sub_menu_list()

    def execute_all_selected_plugins(self):
        if self.selected_plugins:
            self.session.openWithCallback(self.installation_finished,
                InstallProgressScreen, self.selected_plugins, self.installation_finished)
        else:
            self.session.open(MessageBox, "No plugins selected.", MessageBox.TYPE_INFO)

    def installation_finished(self, *args):
        self.selected_plugins = []
        self.update_sub_menu_list()

    def update_plugin(self):
        self.check_for_updates()

    def restart_enigma2(self):
        self.session.openWithCallback(self.confirm_restart, MessageBox,
            "Restart Enigma2 now?", MessageBox.TYPE_YESNO)

    def confirm_restart(self, answer):
        if answer:
            self.session.open(TryQuitMainloop, 3)

    def exit(self):
        self.close()

    def update_time(self):
        pass

    def check_for_updates(self):
        if getattr(self, "version_check_in_progress", False):
            return
        self.version_check_in_progress = True
        self["status"].setText("Checking for updates...")
        self.version_buffer = b""
        self.update_container = eConsoleAppContainer()
        self.update_container.dataAvail.append(self.version_data_avail)
        self.update_container.appClosed.append(self.version_check_closed)
        self.update_container.execute(f"wget -q -O - {VERSION_URL}")

    def version_data_avail(self, data):
        self.version_buffer += data

    def version_check_closed(self, retval):
        self.version_check_in_progress = False
        if retval == 0:
            remote = self.version_buffer.decode().strip()
            if remote != PLUGIN_VERSION:
                self.session.openWithCallback(self.start_update, MessageBox,
                    f"Update available ({remote}). Install now?", MessageBox.TYPE_YESNO)
            else:
                self["status"].setText("Plugin is up to date.")
        else:
            self["status"].setText("Update check failed.")

    def start_update(self, answer):
        if not answer:
            return
        self["status"].setText("Updating plugin...")
        self.update_container = eConsoleAppContainer()
        self.update_container.appClosed.append(self.update_completed)
        self.update_container.execute(
            f"wget -q -O /tmp/smart-Panel.sh {UPDATE_SCRIPT_URL} && chmod +x /tmp/smart-Panel.sh && /tmp/smart-Panel.sh"
        )

    def update_completed(self, retval):
        if retval == 0:
            self["status"].setText("Update successful. Restarting...")
            self.session.open(TryQuitMainloop, 3)
        else:
            self["status"].setText("Update failed.")

def Plugins(**kwargs):
    return [PluginDescriptor(
        name="Smart Addons Panel",
        description="Manage plugins and tools",
        where=PluginDescriptor.WHERE_PLUGINMENU,
        icon=PLUGIN_ICON,
        fnc=lambda session: session.open(SmartAddonspanel)
    )]




