#!/bin/sh

found_dir=""

# البحث عن المجلد المطلوب
for dir in /media/hdd /media/usb /media/mmc /media/ba
do
    if [ -d "$dir/xtraEvent/noinfos" ]; then
        echo "> Folder found: $dir/xtraEvent/noinfos"
        found_dir="$dir"
        break
    fi
done

sleep 1

# التحقق مما إذا تم العثور على المجلد قبل الحذف
if [ -n "$found_dir" ]; then
    echo "> Removing unnecessary files, please wait..."
    sleep 3
    rm -rf "$found_dir/xtraEvent/noinfos/"*.json >/dev/null 2>&1
    echo "> Done."
else
    echo "> Folder not found. No files removed."
fi

sleep 2
exit 0


