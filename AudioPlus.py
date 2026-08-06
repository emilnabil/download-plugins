# -*- coding: utf-8 -*-

from Plugins.Plugin import PluginDescriptor
from Screens.Screen import Screen
from Components.Label import Label
from Components.ActionMap import ActionMap
from Screens.Console import Console
from Screens.MessageBox import MessageBox
from enigma import eEPGCache, eTimer, loadJPG, eConsoleAppContainer, getDesktop, eListboxPythonMultiContent, RT_HALIGN_LEFT, RT_VALIGN_CENTER, RT_WRAP
from Components.config import config, configfile, ConfigYesNo, ConfigSubsection, getConfigListEntry, ConfigSelection, ConfigText, ConfigPassword, ConfigSelectionNumber, ConfigDirectory
from Components.ConfigList import ConfigListScreen
from Components.MenuList import MenuList
from Components.Pixmap import Pixmap
from Screens.LocationBox import LocationBox
from Components.MultiContent import MultiContentEntryText, MultiContentEntryPixmapAlphaBlend, MultiContentEntryProgress, MultiContentEntryPixmapAlphaTest
import threading
import os, io
import json
import sys
import NavigationInstance
from twisted.internet import threads, reactor
from ServiceReference import ServiceReference
import datetime
from time import time, localtime, strftime, sleep
from Screens.VirtualKeyBoard import VirtualKeyBoard
from six.moves import reload_module
from . import skins
reload_module(skins)
from Tools.LoadPixmap import LoadPixmap
try:
    from urllib.request import Request, urlopen
except ImportError:
    from urllib2 import Request, urlopen

try:
    from enigma import eAlsaOutput
    ALSA = True
except:
    ALSA = False

try:
    if os.path.exists("/var/lib/dpkg"):
        Dream = True
    else:
        Dream = False
except:
    pass

scale = None
try:
    if Dream:
        from enigma import SCALE_ASPECT
        scale = SCALE_ASPECT
    elif os.path.exists("/usr/lib/enigma2/python/Tools/HardwareInfoVU.py") or os.path.exists("/usr/lib/enigma2/python/Tools/HardwareInfoVU.pyo") or os.path.exists("/usr/lib/enigma2/python/Tools/HardwareInfoVU.pyc"):
        from enigma import BT_SCALE, BT_FIXRATIO
        scale = BT_SCALE | BT_FIXRATIO
    else:
        from enigma import BT_SCALE, BT_KEEP_ASPECT_RATIO
        scale = BT_SCALE | BT_KEEP_ASPECT_RATIO
except:
    pass

from enigma import addFont, gFont
addFont("/usr/lib/enigma2/python/Plugins/Extensions/AudioPlus/fonts/digicon.ttf", "di", 100, 1)
addFont("/usr/lib/enigma2/python/Plugins/Extensions/AudioPlus/fonts/arial.ttf", "Regular", 100, 1)

try:
    from Plugins.Extensions.AudioPlus import apx
    version = apx.version
except:
    version = ""
rev = "_r010"
desktop_size = getDesktop(0).size().width()

config.plugins.ipap = ConfigSubsection()
config.plugins.ipap.updt = ConfigYesNo(default=True)
config.plugins.ipap.sync = ConfigSelection(default="alsasink", choices=[
    ("alsasink", _("alsasink")),
    ("osssink", _("osssink")),
    ("autoaudiosink", _("autoaudiosink"))])
config.plugins.ipap.skin = ConfigSelection(default="Black", choices=[("Black"), ("Dark"), ("Pastel"), ("Blue"), ("DarkBlue")])
config.plugins.ipap.vol = ConfigSelectionNumber(1, 10, 1, default=5)
config.plugins.ipap.buf = ConfigSelectionNumber(0, 2000, 10, default=500)
config.plugins.ipap.plyr = ConfigSelection(default="Player MAIN", choices=[("Player MAIN"), ("Player MAIN 2"), ("Player MAIN 3"), ("Player MAIN 4"), ("Player 1"), ("Player 2"), ("Player 3")])
config.plugins.ipap.styles = ConfigSelection(default="Style 1", choices=[("Style 1"), ("Style 2"), ("Style 3")])
config.plugins.ipap.piconLoc = ConfigDirectory(default='')
config.plugins.ipap.ac = ConfigSelection(default="-1", choices=[("-1", _("Disable")), ("oss"), ("hw")])

try:
    piconLocation = config.plugins.ipap.piconLoc.value
except:
    try:
        picon_loc = ["/media/cf/picon/","/media/mmc/picon/","/media/usb/picon/","/media/hdd/picon/","/usr/share/enigma2/picon/","/picon/"]
        for i in picon_loc:
            if os.path.isdir(i):
                piconLocation = i
                break
    except:
        piconLocation = "/media/hdd/picon/"

def _get_remote_version():
    try:
        url = "https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/AudioPlus/version.txt"
        request = Request(url)
        response = urlopen(request, timeout=5)
        remote_version = response.read().decode('utf-8').strip()
        return remote_version
    except Exception as err:
        return None

class AudioPlus(Screen):
    def __init__(self, session):
        Screen.__init__(self, session)
        self.session = session
        try:
            if config.plugins.ipap.skin.value == "Black":
                self.skin = skins.black
            elif config.plugins.ipap.skin.value == "Dark":
                self.skin = skins.dark
            elif config.plugins.ipap.skin.value == "Blue":
                self.skin = skins.blue
            elif config.plugins.ipap.skin.value == "DarkBlue":
                self.skin = skins.darkBlue
            elif config.plugins.ipap.skin.value == "Pastel":
                self.skin = skins.pastel
            self["list"] = MenuList([], enableWrapAround=True, content=eListboxPythonMultiContent)
            if desktop_size <= 1280:
                if config.plugins.ipap.styles.value == "Style 1":
                    self["list"].l.setItemHeight(34)
                elif config.plugins.ipap.styles.value == "Style 2":
                    self["list"].l.setItemHeight(34)
                elif config.plugins.ipap.styles.value == "Style 3":
                    self["list"].l.setItemHeight(50)
                self["list"].l.setFont(0, gFont('Regular', 16))
                self["list"].l.setFont(1, gFont('Regular', 12))
            else:
                if config.plugins.ipap.styles.value == "Style 1":
                    self["list"].l.setItemHeight(40)
                elif config.plugins.ipap.styles.value == "Style 2":
                    self["list"].l.setItemHeight(40)
                elif config.plugins.ipap.styles.value == "Style 3":
                    self["list"].l.setItemHeight(75)
                self["list"].l.setFont(0, gFont('Regular', 26))
                self["list"].l.setFont(1, gFont('Regular', 20))
        except Exception as err:
            self.errorlog(err)
        self.epgcache = eEPGCache.getInstance()
        self["picon"] = Pixmap()
        self["actions"] = ActionMap(["AudioPlusAction"], {
            "left": self.keyLeft,
            "right": self.keyRight,
            "down": self.keyDown,
            "up": self.keyUp,
            "pageUp": self.pageUp,
            "pageDown": self.pageDown,
            "ok": self.keyOk,
            "green": self.audioList,
            "yellow": self.audioList,
            "blue": self.resetAudio,
            "red": self.exit,
            "cancel": self.exit,
            "menu": self.mn,
            "info": self.inf,
        }, -1)
        self['title'] = Label()
        self['audioSource'] = Label()
        self['status'] = Label()
        self['info'] = Label()
        self['curCh'] = Label()
        self['now_evnt'] = Label()
        self['next_evnt'] = Label()
        self['desc'] = Label()
        self.act = False
        self.onCh = NavigationInstance.instance.getCurrentlyPlayingServiceReference()
        self.container = eConsoleAppContainer()
        self.piconLocation = config.plugins.ipap.piconLoc.value
        try:
            self.alsa = None
            if ALSA:
                self.alsa = eAlsaOutput.getInstance()
            if Dream:
                threads.deferToThread(self.getAct())
            else:
                self.onLayoutFinish.append(self.start)
        except Exception as err:
            self.errorlog(err)

    def getAct(self):
        self.act = True
        try:
            self.audiopluslis = self.load_channels_from_json()
        except:
            self.audiopluslis = []
        self['status'].hide()
        self['title'].setText(_("AudioPlus {}".format(version)))
        self.audioList()

    def load_channels_from_json(self):
        channels = []
        json_path = "/etc/enigma2/audio.json"
        try:
            if os.path.exists(json_path):
                with io.open(json_path, encoding="utf-8") as f:
                    data = json.load(f)
                    if isinstance(data, list) and data and isinstance(data[0], list):
                        channels = data[0]
                    elif isinstance(data, list):
                        channels = data
        except Exception as err:
            self.errorlog(err)
        return channels

    def start(self):
        try:
            threading.Thread(target=self.getAct, args=()).start()
        except Exception as err:
            self.errorlog(err)

    def audioList(self):
        try:
            self['audioSource'].setText(_("Audio Source : AudioPlus"))
            self['info'].setText(_("Server 1"))
            self['info'].show()
            eventName = ""
            self.list=[]
            for i in range(len(self.audiopluslis)):
                self.list.append([" {}".format(self.audiopluslis[i]["name"]), self.audiopluslis[i]["url"], self.audiopluslis[i]["ref"]])
            endlist=[]
            for i in range(len(self.list)):
                pcn1 = LoadPixmap(cached=False, path="/usr/lib/enigma2/python/Plugins/Extensions/AudioPlus/plugin.png")
                self.eventName = ""
                self.evnt(i)
                serviceName = self.list[i][0]
                try:
                    pcn1 = LoadPixmap(cached=False, path=self.piconName)
                except:
                    pcn1 = LoadPixmap(cached=False, path="/usr/lib/enigma2/python/Plugins/Extensions/AudioPlus/plugin.png")
                if config.plugins.ipap.styles.value == "Style 1":
                    if desktop_size <= 1280:
                        endlist.append([
                            (),
                            (eListboxPythonMultiContent.TYPE_TEXT, 10,0,480,36, 0, RT_HALIGN_LEFT, str(serviceName), 0x00ffffff, 0x00ffffff, None, None),
                        ])
                    else:
                        endlist.append([
                            (),
                            (eListboxPythonMultiContent.TYPE_TEXT, 10,5,770,36, 0, RT_HALIGN_LEFT, str(serviceName), 0x00ffffff, 0x00ffffff, None, None),
                        ])
                elif config.plugins.ipap.styles.value == "Style 2":
                    pichd = (eListboxPythonMultiContent.TYPE_PIXMAP_ALPHATEST, 7,2,50,30, pcn1, None, None, scale)
                    picfhd = (eListboxPythonMultiContent.TYPE_PIXMAP_ALPHATEST, 7,0,66,40, pcn1, None, None, scale)
                    if desktop_size <= 1280:
                        endlist.append([
                            (),
                            pichd,
                            (eListboxPythonMultiContent.TYPE_TEXT, 60,0,480,36, 0, RT_HALIGN_LEFT, "{} ({})".format(serviceName, self.eventName), 0x00ffffff, 0x00ffffff, None, None),
                            (eListboxPythonMultiContent.TYPE_PROGRESS, 550,15,40,6, self.progress, 1, 0x00ffffff, 0x00ffffff, None, None),
                        ])
                    else:
                        endlist.append([
                            (),
                            picfhd,
                            (eListboxPythonMultiContent.TYPE_TEXT, 80,5,750,36, 0, RT_HALIGN_LEFT, "{} ({})".format(serviceName, self.eventName), 0x00ffffff, 0x00ffffff, None, None),
                            (eListboxPythonMultiContent.TYPE_PROGRESS, 850,15,60,10, self.progress, 1, 0x00ffffff, 0x00ffffff, None, None),
                        ])
                elif config.plugins.ipap.styles.value == "Style 3":
                    pichd = (eListboxPythonMultiContent.TYPE_PIXMAP_ALPHATEST, 2,2,66,40, pcn1, None, None, scale)
                    picfhd = (eListboxPythonMultiContent.TYPE_PIXMAP_ALPHATEST, 5,5,100,60, pcn1, None, None, scale)
                    if desktop_size <= 1280:
                        endlist.append([
                            (),
                            pichd,
                            (eListboxPythonMultiContent.TYPE_TEXT, 75,2,500,24, 0, RT_HALIGN_LEFT, serviceName, 0x00ffffff, 0x00ffffff, None, None),
                            (eListboxPythonMultiContent.TYPE_TEXT, 80,26,500,24, 0, RT_HALIGN_LEFT, self.eventName, 0x00ffffff, 0x00ffffff, None, None),
                            (eListboxPythonMultiContent.TYPE_PROGRESS, 5,40,60,5, self.progress, 1, 0x00ffffff, 0x00ffffff, None, None),
                        ])
                    else:
                        endlist.append([
                            (),
                            picfhd,
                            (eListboxPythonMultiContent.TYPE_TEXT, 110,7,750,36, 0, RT_HALIGN_LEFT, serviceName, 0x00ffffff, 0x00ffffff, None, None),
                            (eListboxPythonMultiContent.TYPE_TEXT, 115,40,750,36, 0, RT_HALIGN_LEFT, self.eventName, 0x00ffffff, 0x00ffffff, None, None),
                            (eListboxPythonMultiContent.TYPE_PROGRESS, 5,65,100,7, self.progress, 1, 0x00ffffff, 0x00ffffff, None, None),
                        ])
            self["list"].l.setList(endlist)
            self["list"].show()
            self["list"].moveToIndex(0)
            self.CurrentSrvc()
            if config.plugins.ipap.updt.value == True:
                remote_version = _get_remote_version()
                if remote_version is not None and version != remote_version:
                    up_msg = _("New version available!\n\nCurrent: {}\nLatest: {}\n\nDo you want to update now?").format(version, remote_version)
                    self.session.openWithCallback(self.instalUpdate, MessageBox, up_msg, MessageBox.TYPE_YESNO)
        except Exception as err:
            self.errorlog(err)

    def instalUpdate(self, answer):
        try:
            if answer is True:
                cmd = ['wget -q "--no-check-certificate" https://github.com/emilnabil/download-plugins/raw/refs/heads/main/AudioPlus/AudioPlus.sh -O - | /bin/sh']
                self.session.open(Console, title=_('Updating AudioPlus...'), cmdlist=cmd, finishedCallback=self.finished, closeOnSuccess=False)
        except Exception as err:
            self.errorlog(err)

    def finished(self, result=None):
        return

    def keyOk(self):
        try:
            self.index = self['list'].getSelectionIndex()
            url = self.list[self.index][1]
            if url:
                self.urlAudio(url)
                self['audioSource'].setText(_("Audio Source : {}".format(self.list[self.index][0])))
        except Exception as err:
            self.errorlog(err)

    def urlAudio(self, url):
        try:
            self.resetAudio()
            sync = "alsasink"
            buffer = 10
            vol = float(5) / float(10)
            sync = config.plugins.ipap.sync.value
            buffer = config.plugins.ipap.buf.value
            userAgent = "Tialiaudioolayer"
            userAgent_2 = "Lavf/60.3.100"
            userAgent_3 = "Lavf/57.83.100"
            userAgent_4 = "Lavf/59.27.100"
            if config.plugins.ipap.plyr.value == "Player 1":
                vol = float(config.plugins.ipap.vol.value) / float(10)
                cmd = 'gst-launch-1.0 playbin uri={} audio-sink={} volume={}'.format(url, sync, vol)
            elif config.plugins.ipap.plyr.value == "Player 2":
                cmd = 'gst-launch-1.0 fdsrc fd=0 {} ! decodebin ! audioconvert ! audioresample ! {}'.format(url, sync)
            elif config.plugins.ipap.plyr.value == "Player 3":
                cmd = '(/usr/bin/gst-launch-1.0 fdsrc fd=0 {} ! decodebin ! queue2 use-buffering=true max-size-buffers={} max-size-bytes=0 max-size-time=0 ! {} device=hw:0)>/dev/null 2>&1'.format(url, buffer, sync)
            elif config.plugins.ipap.plyr.value == "Player MAIN":
                cmd = 'gst-launch-1.0 souphttpsrc location={} user-agent="{}" ! decodebin ! audioconvert ! audioresample ! queue max-size-buffers=500 max-size-time=0 max-size-bytes=0 ! {} sync=false'.format(url, userAgent, sync)
            elif config.plugins.ipap.plyr.value == "Player MAIN 2":
                cmd = 'gst-launch-1.0 souphttpsrc location={} user-agent="{}" ! decodebin ! audioconvert ! audioresample ! queue max-size-buffers=500 max-size-time=0 max-size-bytes=0 ! {} sync=false'.format(url, userAgent_2, sync)
            elif config.plugins.ipap.plyr.value == "Player MAIN 3":
                cmd = 'gst-launch-1.0 souphttpsrc location={} user-agent="{}" ! decodebin ! audioconvert ! audioresample ! queue max-size-buffers=500 max-size-time=0 max-size-bytes=0 ! {} sync=false'.format(url, userAgent_3, sync)
            elif config.plugins.ipap.plyr.value == "Player MAIN 4":
                cmd = 'gst-launch-1.0 souphttpsrc location={} user-agent="{}" ! decodebin ! audioconvert ! audioresample ! queue max-size-buffers=500 max-size-time=0 max-size-bytes=0 ! {} sync=false'.format(url, userAgent_4, sync)
            if self.alsa:
                self.alsa.stop()
                self.alsa.close()
                self.container.execute(cmd)
            else:
                if os.path.exists('/dev/dvb/adapter0/audio0'):
                    self.session.nav.stopService()
                    os.rename('/dev/dvb/adapter0/audio0', '/dev/dvb/adapter0/audio10')
                    self.container.execute(cmd)
                    self.session.nav.playService(self.onCh)
        except Exception as err:
            self.errorlog(err)

    def resetAudio(self):
        try:
            os.system('killall -9 gst-launch-1.0 >/dev/null 2>&1')
            if self.container.running():
                self.container.kill()
            if not self.alsa:
                if os.path.exists('/dev/dvb/adapter0/audio10'):
                    self.session.nav.stopService()
                    os.rename('/dev/dvb/adapter0/audio10', '/dev/dvb/adapter0/audio0')
                    self.session.nav.playService(self.onCh)
                else:
                    return
            self['audioSource'].setText(_("Audio Source : Current"))
        except Exception as err:
            self.errorlog(err)

    def evnt(self, i):
        try:
            self.eventName = "N/A"
            self.progress = 0
            ref = str(self.list[i][2]).replace("_", ":")
            try:
                serviceName = ServiceReference(ref).getServiceName()
                events = self.epgcache.lookupEvent(['IBDCT', (ref, 0, -1, 1)])
                event = events[0][4]
                self.progress = 0
                self.eventName = event
                self.progress = (int(time()) - events[0][1]) * 100 // events[0][2]
            except:
                self.eventName = "N/A"
                self.progress = 0
            try:
                picon_name = str(piconLocation) + str(ref).replace(':', '_') + '.png'
                if os.path.exists(picon_name):
                    self.piconName = picon_name
                    return
                else:
                    picon_name = "{}{}.png".format(piconLocation, serviceName.replace('&', 'and').replace('+', 'plus').replace('*', 'star').replace(' ', ''))
                    picon_name = picon_name.strip().lower()
                    if os.path.exists(picon_name):
                        self.piconName = picon_name
                        return
                    else:
                        self.piconName = "/usr/lib/enigma2/python/Plugins/Extensions/AudioPlus/plugin.png"
                        return
            except:
                pass
        except Exception as err:
            self.errorlog(err)

    def CurrentSrvc(self):
        try:
            epg = eEPGCache.getInstance()
            event = epg.lookupEventTime(self.onCh, -1, 0)
            serviceName = ServiceReference(self.onCh).getServiceName()
            self['curCh'].setText(_(" {}".format(serviceName)))
            if event:
                event_name = event.getEventName()
                short_desc = event.getShortDescription()
                extend_desc = event.getExtendedDescription()
                self['now_evnt'].setText(_(" {}".format(event_name)))
                self['desc'].setText(_("{}\n{}".format(short_desc, extend_desc)))
            try:
                picon_name = str(piconLocation) + str(self.onCh.toString()) + '.png'
                picon_name = picon_name.replace('_', '')
                if os.path.exists(picon_name):
                    self["picon"].instance.setPixmapFromFile(picon_name)
                    self["picon"].instance.setScale(1)
                    self["picon"].instance.show()
                else:
                    picon_name = "{}{}.png".format(piconLocation, serviceName.replace('&', 'and').replace('+', 'plus').replace('*', 'star').replace(' ', ''))
                    picon_name = self.piconName.strip().lower()
                    if os.path.exists(picon_name):
                        self["picon"].instance.setPixmapFromFile(picon_name)
                        self["picon"].instance.setScale(1)
                        self["picon"].instance.show()
                    else:
                        picon_name = "/usr/share/enigma2/picon_default.png"
                        self["picon"].instance.setPixmapFromFile(picon_name)
                        self["picon"].instance.setScale(1)
                        self["picon"].instance.show()
            except Exception as err:
                self.errorlog(err)
        except Exception as err:
            self.errorlog(err)

    def keyDown(self):
        try:
            self["list"].instance.moveSelection(self["list"].instance.moveDown)
        except:
            pass

    def keyUp(self):
        try:
            self["list"].instance.moveSelection(self["list"].instance.moveUp)
        except:
            pass

    def keyRight(self):
        try:
            self["list"].instance.moveSelection(self["list"].instance.pageDown)
        except:
            pass

    def keyLeft(self):
        try:
            self["list"].instance.moveSelection(self["list"].instance.pageUp)
        except:
            pass

    def pageUp(self):
        try:
            self["list"].instance.moveSelection(self["list"].instance.pageDown)
        except:
            pass

    def pageDown(self):
        try:
            self["list"].instance.moveSelection(self["list"].instance.pageUp)
        except:
            pass

    def mn(self):
        try:
            self.session.openWithCallback(self.exit2, MenuSetup)
        except Exception as err:
            self.errorlog(err)

    def exit2(self, ret=False):
        if ret:
            self.close()

    def inf(self):
        try:
            if self.act == True:
                self.session.open(info)
            else:
                self['status'].setText(_("Activation NO !!!"))
                self['status'].show()
        except Exception as err:
            self.errorlog(err)

    def errorlog(self, err):
        import sys
        nt = localtime()
        tm = '{:02d}:{:02d}:{:02d}'.format(nt.tm_hour, nt.tm_min, nt.tm_sec)
        with open("/tmp/AudioPlus.log", "a+") as f:
            f.write("[{}], {}, line:{}\n".format(tm, err, sys.exc_info()[2].tb_lineno))

    def exit(self):
        self.audiopluslis = []
        import gc
        gc.collect()
        self.close(True)

class MenuSetup(Screen, ConfigListScreen):
    def __init__(self, session):
        Screen.__init__(self, session)
        if config.plugins.ipap.skin.value == "Black":
            self.skin = skins.black_setup
        elif config.plugins.ipap.skin.value == "Dark":
            self.skin = skins.dark_setup
        elif config.plugins.ipap.skin.value == "Blue":
            self.skin = skins.blue_setup
        elif config.plugins.ipap.skin.value == "DarkBlue":
            self.skin = skins.darkBlue_setup
        elif config.plugins.ipap.skin.value == "Pastel":
            self.skin = skins.pastel_setup
        self.list = []
        ConfigListScreen.__init__(self, self.list, on_change=self.changed)
        self["actions"] = ActionMap(["AudioPlusAction"],
            {
            "left": self.keyLeft,
            "right": self.keyRight,
            "down": self.keyDown,
            "up": self.keyUp,
            "cancel":self.close,
            "green":self.save,
            "ok":self.keyOK,
            "yellow":self.update,
            "blue":self.vk,
            }, -1)
        self.setTitle(_("AudioPlus"))
        self['status'] = Label(_('_'))
        self['info'] = Label(_(None))
        self['Picture'] = Pixmap()
        self.onLayoutFinish.append(self.mns)

    def keyLeft(self):
        ConfigListScreen.keyLeft(self)
        self.reloadConfig()

    def keyRight(self):
        ConfigListScreen.keyRight(self)
        self.reloadConfig()

    def keyDown(self):
        self["config"].instance.moveSelection(self["config"].instance.moveDown)
        self.reloadConfig()

    def keyUp(self):
        self["config"].instance.moveSelection(self["config"].instance.moveUp)
        self.reloadConfig()

    def mns(self):
        try:
            self.list = []
            self.list.append((getConfigListEntry(" AUDIO SINK", config.plugins.ipap.sync)))
            self.list.append((getConfigListEntry(" AUDIO CONF", config.plugins.ipap.ac)))
            self.list.append((getConfigListEntry(" PLAYER", config.plugins.ipap.plyr)))
            if config.plugins.ipap.plyr.value == "Player 1":
                self.list.append((getConfigListEntry(" VOLUME", config.plugins.ipap.vol)))
            if config.plugins.ipap.plyr.value == "Player 3":
                self.list.append((getConfigListEntry(" BUFFER", config.plugins.ipap.buf)))
            self.list.append((getConfigListEntry(" SKIN", config.plugins.ipap.skin)))
            self.list.append((getConfigListEntry(" SKIN STYLES", config.plugins.ipap.styles)))
            self.list.append((getConfigListEntry(" PICON LOCATION [ OK ]", config.plugins.ipap.piconLoc)))
            self.list.append((getConfigListEntry(" AUTO UPDATE CHECK", config.plugins.ipap.updt)))
            self["config"].list = self.list
            self["config"].l.setList(self.list)
            self.showImg()
        except Exception as err:
            self.errorlog(err)

    def keyOK(self):
        picloc="/"
        if self['config'].getCurrent()[1] is config.plugins.ipap.piconLoc:
            self.session.openWithCallback(self.pathSelected1, LocationBox, text=_('Default Folder'), currDir=picloc, minFree=100)

    def pathSelected1(self, res):
        if res is not None:
            config.plugins.ipap.piconLoc.value = res
            self.reloadConfig()

    def changed(self):
        self.reloadConfig()

    def reloadConfig(self):
        self.list = []
        self.mns()
        self["config"].setList(self.list)

    def vk(self):
        if config.plugins.ipap.actCode.value:
            act = config.plugins.ipap.actCode.value
        else:
            act = ""
        self.session.openWithCallback(self.vkEdit, VirtualKeyBoard, title="Activation Code Input", text = str(act))

    def vkEdit(self, text=None):
        try:
            if text:
                config.plugins.ipap.actCode.value = text
                config.plugins.ipap.actCode.save()
                configfile.save()
        except Exception as err:
            self.errorlog(err)

    def showImg(self):
        try:
            picpath = ""
            curline = self["config"].getCurrent()[1].value
            if curline == config.plugins.ipap.skin.value:
                picpath = "/usr/lib/enigma2/python/Plugins/Extensions/AudioPlus/images/preview/{}.jpg".format(curline)
            elif curline == config.plugins.ipap.styles.value:
                picpath = "/usr/lib/enigma2/python/Plugins/Extensions/AudioPlus/images/preview/{}.jpg".format(curline)
            else:
                self['Picture'].instance.hide()
            self["Picture"].instance.setPixmap(loadJPG(picpath))
            self["Picture"].instance.setScale(2)
            if os.path.exists(picpath):
                self['Picture'].instance.show()
            else:
                self['Picture'].instance.hide()
        except Exception as err:
            self.errorlog(err)
            pass

    def update(self):
        try:
            remote_version = _get_remote_version()
            if remote_version is None:
                self['info'].setText(_("Failed to check for updates."))
                return
            if version != remote_version:
                up_msg = _("New version available!\n\nCurrent: {}\nLatest: {}\n\nDo you want to update now?").format(version, remote_version)
                self.session.openWithCallback(self.instalUpdate, MessageBox, up_msg, MessageBox.TYPE_YESNO)
            else:
                self['info'].setText(_("You are using the latest version: {}").format(version))
        except Exception as err:
            self.errorlog(err)

    def instalUpdate(self, answer):
        try:
            if answer is True:
                cmd = ['wget -q "--no-check-certificate" https://github.com/emilnabil/download-plugins/raw/refs/heads/main/AudioPlus/AudioPlus.sh -O - | /bin/sh']
                self.session.open(Console, title=_('Updating AudioPlus...'), cmdlist=cmd, finishedCallback=self.finished, closeOnSuccess=False)
        except Exception as err:
            self.errorlog(err)

    def finished(self, result=None):
        return

    def save(self):
        for x in self["config"].list:
            if len(x) >= 1:
                x[1].save()
        configfile.save()
        ossConf = "pcm.!default {\n\
    type oss\n\
    device /dev/dsp\n\
}\n\
\n\
ctl.!default {\n\
    type oss\n\
    device /dev/mixer\n\
}"
        hwConf="pcm.!default {\n\
    type hw\n\
    card 0\n\
    device 0\n\
}\n\
\n\
ctl.!default {\n\
    type hw\n\
    card 0\n\
}"
        if config.plugins.ipap.ac.value == "oss":
            with open("/etc/asound.conf", "w") as f:
                f.write(str(ossConf))
        elif config.plugins.ipap.ac.value == "hw":
            with open("/etc/asound.conf", "w") as f:
                f.write(str(hwConf))
        else:
            with open("/etc/asound.conf", "w") as f:
                f.write(str(hwConf))
        self.close(True)

    def errorlog(self, err):
        import sys
        nt = localtime()
        tm = '{:02d}:{:02d}:{:02d}'.format(nt.tm_hour, nt.tm_min, nt.tm_sec)
        with open("/tmp/AudioPlus.log", "a+") as f:
            f.write("[{}]mn, {}, line:{}\n".format(tm, err, sys.exc_info()[2].tb_lineno))

class info(Screen):
    skin = '''
<screen name="info" position="center,center" size="700,330" flags="wfNoBorder" backgroundColor="#50000000">
    <widget name="info" position="20,20" font="Regular; 30" size="680,280" foregroundColor="#00ffffff" backgroundColor="#50000000" zPosition="1" transparent="1" halign="left" valign="center" />
</screen>'''
    def __init__(self, session):
        Screen.__init__(self, session)
        self["actions"] = ActionMap(["AudioPlusAction"],
            {
                "cancel":self.close,
                "ok":self.close,
            }, -2)
        self['info'] = Label()
        self.mc()

    def mc(self):
        mac = "N/A"
        try:
            os.system("ifconfig eth0 | awk '/HWaddr/ {print $5}' > /etc/.mac")
            if os.path.exists("/etc/.mac"):
                with open("/etc/.mac", "r") as f:
                    macaddr = f.read()
        except:
            pass
        self['info'].setText("(c) AudioPlus {}{}\n\nMac Address = {}".format(version, rev, macaddr))
