#!/bin/sh

echo "> Removing sources files, please wait..."
sleep 2

cd /etc/epgimport || exit 1

for f in *; do
    case "$f" in
        custom.sources.xml|xstreamity.sources.xml)
            # Skip these files
            ;;
        *)
            rm -f "$f" >/dev/null 2>&1
            ;;
    esac
done

echo "> Done."
sleep 2
exit 0

