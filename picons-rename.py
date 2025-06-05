#!/usr/bin/python
# -*- coding: utf-8 -*-

import unicodedata
import re
import os
import glob
import zipfile
import sys
if sys.version_info[0] >= 3:
    unicode = str


def normalize(title):
    try:
        try:
            return title.decode('ascii').encode("utf-8")
        except:
            pass

        return str(''.join(c for c in unicodedata.normalize('NFKD', unicode(title.decode('utf-8'))) if unicodedata.category(c) != 'Mn'))
    except:
        return unicode(title)


def renamePicons():
    print("This plugin by @abu baniaz, search picons and rename to SNP(ame)\nmake a zip file /tmp/picons.zip\nAdapted from Lululla for Linuxsat-support.com")
    tmpPicon = "/tmp/picon/"
    tmpLamedb = "/tmp/lamedb"
    if os.path.exists(tmpLamedb):
        lamedb = tmpLamedb
    else:
        lamedb = "/etc/enigma2/lamedb"
    piconLocations = ["/usr/share/enigma2/picon/", "/picon/", "/media/usb/picon/", "/media/hdd/picon/", "/media/hdd2/picon/", "/media/cf/picon/", "/media/sdb/picon/", "/media/sdb2/picon/",]
    outfile = "/tmp/picons.zip"
    outlog1 = "found-picons"
    outlog2 = "omitted-picons"
    outlog3 = "impossible-picons"
    logExt = ".csv"
    piconOutFolder = "/picon/"
    messages1 = []
    messages2 = {}
    messages3 = []
    paths = []
    pattern = "1_0_*_*_*_*_*_0_0_0.png"
    print("Searching for picons...")
    if os.path.isdir(tmpPicon):
        paths = glob.glob(tmpPicon + pattern)
    else:
        for lx in piconLocations:
            paths = paths + glob.glob(lx + pattern)
    pathsSplit = []
    for p in paths:
        pathsSplit.append(p.rsplit('/', 1))
    del (paths)
    paths = {}
    types = []
    print("Processing paths...")
    for p in pathsSplit:
        parts = p[1].split('_', 3)
        # types.append(parts[2])
        f = p[0] + '/' + p[1]
        n = "1_0_*_%s" % (parts[3])
        if os.path.islink(f):
            f = p[0] + '/' + os.readlink(f)
            if os.path.exists(f):
                paths[n] = f
        else:
            paths[n] = f
    print("sorted(list(set(array)))", sorted(list(set(types))))
    # return
    del (pathsSplit)
    print("Reading lamedb...")
    f = open(lamedb).readlines()
    f = f[f.index("services\n") + 1: -3]
    i = 0
    done = []
    zf = zipfile.ZipFile(outfile, mode='w', compression=zipfile.ZIP_DEFLATED)
    while len(f) > 2:
        ref = [x for x in f[0][:-1].split(':')]
        slot = slot1(ref[1])
        sat = slotName(ref[1])
        refstr = "1:0:*:%X:%X:%X:%X:0:0:0" % (int(ref[0], 0x10), int(ref[2], 0x10), int(ref[3], 0x10), int(ref[1], 0x10))
        serviceType = str(hex(int(ref[4]))).replace('0x', '')  # just for the log
        types.append(int(serviceType, 0x10))
        refstr2 = "1:0:%s:%X:%X:%X:%X:0:0:0" % (serviceType, int(ref[0], 0x10), int(ref[2], 0x10), int(ref[3], 0x10), int(ref[1], 0x10))  # just for the log
        # ref = f[0][:-1] # service ref string from lamedb
        name = f[1][:-1]
        f = f[3:]  # for next iteration
        oldPiconName = refstr.replace(':', '_') + ".png"
        # newName1 = unicodedata.normalize('NFKD', unicode(name, 'utf_8')).encode('ASCII', 'ignore')
        newName1 = normalize(name)
        newName2 = re.sub('[^a-z0-9]', '', newName1.replace('&', 'and').replace('+', 'plus').replace('*', 'star').lower())
        newPiconName = newName2 + ".png"
        if len(newName2):
            if oldPiconName in paths:
                if newPiconName not in done:
                    done.append(newPiconName)
                    zf.write(paths[oldPiconName], arcname=piconOutFolder + newPiconName)
                    messages1.append(('"' + newName1 + '"', newPiconName, sat, refstr2))
                    i += 1
                    if i % 100 == 0:
                        print("Created %i picons... " % (i))
                else:
                    messages1.append(('"' + newName1 + '"', "picon shared (%s)." % (newPiconName), sat, refstr2))
            else:
                if slot not in messages2:
                    messages2[slot] = []
                messages2[slot].append(('"' + newName1 + '"', newPiconName, sat, refstr2))
        else:
            messages3.append(('"' + newName1 + '"', "zero length picon name", sat, refstr2))
    print("Created %i picons..." % (i))

    print("Sorting logs...")
    messages1 = sortByValue(messages1, 0)
    # messages2 = sortByValue(messages2, 0)
    messages3 = sortByValue(messages3, 2)

    print("Writing picons-found log...")
    log1 = ''
    for m in messages1:
        log1 += ', '.join(m) + "\n"
    zf.writestr(outlog1 + logExt, log1)

    print("Writing picons-missing logs...")
    log2 = ''
    slots = sorted(messages2.keys())
    for slot in slots:
        missing = sortByValue(messages2[slot], 0)
        for m in missing:
            log2 += ', '.join(m) + "\n"
    zf.writestr(outlog2 + logExt, log2)

    print("Writing picons-impossible log...")
    log3 = ''
    for m in messages3:
        log3 += ', '.join(m) + "\n"
    zf.writestr(outlog3 + logExt, log3)

    zf.close()
    print("Task completed. Output saved in %s." % (outfile))
    print("sorted(list(set(array)))", sorted(list(set(types))))


def sortByValue(inputList, sortKey):  # Sort case insensitive
    return sorted(inputList, key=lambda listItem: listItem[sortKey].lower())


def slotName(namespace):
    slot = slot1(namespace)
    return satname(slot)


def satname(slot):
    if slot == 65535:
        return 'cable'
    elif slot == 61166:
        return 'terrestrial'
    while slot < -1800:
        slot += 3600
    while slot > 1800:
        slot -= 3600
    westeast = 'E' if slot >= 0 else 'W'
    return str(round(float(abs(slot)) / 10, 1)) + westeast


def slot1(namespace):
    return int(namespace[:len(namespace) - 4], 16)


renamePicons()
